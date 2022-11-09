# frozen_string_literal: true

require_relative 'core/trigger'

module Nanoci
  # Centralized object to store and access triggers
  class TriggerRepository
    LOCK_WAITING = :waiting
    LOCK_ACQUIRED = :acquired
    LOCK_EXECUTING = :executing

    FIELD_LOCK = :lock_state
    FIELD_LOCK_EXPIRES = :lock_expires
    FIELD_TRIGGER_TYPE = :type

    LOCK_TIMEOUT = 60

    def initialize
      @counter = 0
      @triggers = []
    end

    def add(trigger)
      trigger_memento = trigger.memento
      doc = find_by_tag(trigger_memento[:project_tag], trigger_memento[:tag])
      if doc.nil?
        trigger_memento[FIELD_LOCK] = LOCK_WAITING
        trigger_memento[FIELD_LOCK_EXPIRES] = nil
        insert_doc(memento_to_doc(trigger_memento))
      else
        trigger_memento = doc_to_memento(doc)
      end
      trigger.memento = trigger_memento
    end

    def read_and_lock_next_due_trigger(due_ts:, projects:)
      doc = find_and_lock_due_doc(due_ts: due_ts, projects: projects, state: LOCK_WAITING)
      return nil if doc.nil?

      hydrate_trigger(doc_to_memento(doc))
    end

    def update_and_release_trigger(trigger:)
      memento = trigger.memento
      update_and_release_doc(memento[:id], memento_to_doc(memento))
    end

    def due_triggers?(due_ts:, projects:)
      @triggers.any? { |t| trigger_due?(trigger: t, due_ts: due_ts, projects: projects, state: LOCK_WAITING) }
    end

    protected

    def memento_to_doc(memento)
      doc = memento.clone
      doc[:_id] = doc[:id]
      doc.delete :id
      doc
    end

    def doc_to_memento(doc)
      memento = doc.clone
      memento[:id] = memento[:_id]
      memento.delete :_id
      memento
    end

    def find_by_tag(project_tag, tag)
      @triggers.find { |t| t[:project_tag] == project_tag && t[:tag] == tag }
    end

    def find_and_lock_due_doc(due_ts:, projects:, state:)
      doc = @triggers.find { |t| trigger_due?(trigger: t, due_ts: due_ts, projects: projects, state: state) }
      return nil if doc.nil?

      doc[FIELD_LOCK] = LOCK_EXECUTING
      doc[FIELD_LOCK_EXPIRES] = Time.now.utc + LOCK_TIMEOUT
      doc
    end

    def update_and_release_doc(id, doc)
      stored_memento = @triggers.find { |t| t[:_id] = id && t[FIELD_LOCK] == LOCK_EXECUTING }
      stored_memento.merge!(doc)
      stored_memento[FIELD_LOCK] = LOCK_WAITING
      stored_memento[FIELD_LOCK_EXPIRES] = nil
    end

    def insert_doc(doc)
      doc[:_id] = @counter
      @counter += 1
      @triggers.push doc
    end

    def trigger_due?(trigger:, due_ts:, projects:, state:)
      trigger[:next_run_time] < due_ts && projects.include?(trigger[:project_tag]) && trigger[FIELD_LOCK] == state
    end

    def hydrate_trigger(memento)
      trigger_clazz = Nanoci::Core::Trigger.find_trigger_type memento[FIELD_TRIGGER_TYPE]
      trigger = trigger_clazz.new(tag: memento[:tag], project_tag: memento[:project_tag])
      trigger.memento = memento
      trigger
    end
  end
end
