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
      stored_trigger = @triggers.find { |t| t[:tag] == trigger_memento[:tag] }
      if stored_trigger.nil?
        enchance_initial_memento(trigger_memento)
        @triggers.push trigger_memento
      else
        trigger_memento = stored_trigger
      end
      trigger.memento = trigger_memento
    end

    def read_and_lock_next_due_trigger(now_timestamp)
      trigger_memento = @triggers.find { |t| t[:next_run_time] < now_timestamp && t[FIELD_LOCK] == LOCK_WAITING }
      return nil if trigger_memento.nil?

      trigger_memento[FIELD_LOCK] = LOCK_EXECUTING
      trigger_memento[FIELD_LOCK_EXPIRES] = Time.now.utc + LOCK_TIMEOUT

      hydrate_trigger(trigger_memento)
    end

    def update_and_release_trigger(trigger)
      memento = trigger.memento
      stored_memento = @triggers.find { |t| t[:id] = memento[:id] && t[FIELD_LOCK] == LOCK_EXECUTING }
      stored_memento.merge!(memento)
      stored_memento[FIELD_LOCK] = LOCK_WAITING
      stored_memento[FIELD_LOCK_EXPIRES] = nil
    end

    def due_triggers?(now_timestamp)
      @triggers.any? { |t| t[:next_run_time] < now_timestamp && t[FIELD_LOCK] == LOCK_WAITING }
    end

    protected

    def enchance_initial_memento(memento)
      memento[:id] = @counter
      @counter += 1
      memento[FIELD_LOCK] = LOCK_WAITING
      memento[FIELD_LOCK_EXPIRES] = nil
    end

    def hydrate_trigger(memento)
      trigger_clazz = Nanoci::Core::Trigger.find_trigger_type memento[FIELD_TRIGGER_TYPE]
      trigger = trigger_clazz.new(tag: memento[:tag], project_tag: memento[:project_tag])
      trigger.memento = memento
      trigger
    end
  end
end
