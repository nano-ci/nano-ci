# frozen_string_literal: true

require 'set'

require_relative 'messages/stage_complete_message'
require_relative '../messaging/topic'
require_relative '../system/event'

module Nanoci
  module Core
    # TriggerEngine runs triggers and notify [Nanoci::Core::PipelineEngine] througn callback about trigger event
    class TriggerEngine
      # Initializes new instance of [Nanoci::Core::TriggerEngine]
      # @param trigger_repository [Nanoci::TriggerRepository]
      # @param pipeline_engine [Nanoci::Core::PipelineEngine]
      def initialize(trigger_repository, pipeline_engine)
        @trigger_repository = trigger_repository
        @pipeline_engine = pipeline_engine
        # @type [Hash<Symbol => Nanoci:Core::Project>]
        @enabled_projects = {}
      end

      # Allows triggers of the given project to run on this trigger engine
      # @param project [Nanoci::Core::Project]
      def enable_project(project)
        project.pipeline.triggers.each do |x|
          @trigger_repository.add(x)
        end

        @enabled_projects[project.tag] = project
      end

      # Disables execution of project's triggers on this trigger engine
      def disable_project(project_tag:)
        @enabled_projects.delete project_tag
      end

      def tick(cancellation_token)
        return if cancellation_token.cancellation_requested?

        trigger = read_and_lock_next_due_trigger
        process_trigger(trigger) unless trigger.nil?
      end

      protected

      def read_and_lock_next_due_trigger
        tm = @trigger_repository.read_and_lock_next_due_trigger(due_ts: Time.now.utc, projects: @enabled_projects.keys)
        return nil if tm.nil?

        # @type [Nanoci::Core::Project]
        project = @enabled_projects.fetch(tm[:project_tag])
        t = project.find_trigger(tm[:tag])
        t.memento = tm
        t
      end

      def store_and_release_trigger(trigger)
        @trigger_repository.update_and_release_trigger(trigger: trigger)
      end

      def due_triggers?
        @trigger_repository.due_triggers?(due_ts: Time.now.utc, projects: @enabled_projects.to_a)
      end

      # @param trigger [Nanoci::Core::Trigger]
      def process_trigger(trigger)
        project_tag = trigger.project.tag
        trigger_tag = trigger.full_tag
        outputs = trigger.pulse
        @pipeline_engine.trigger_fired(project_tag, trigger_tag, outputs)
      ensure
        store_and_release_trigger trigger
      end
    end
  end
end
