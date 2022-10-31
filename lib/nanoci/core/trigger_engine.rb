# frozen_string_literal: true

require 'set'

require_relative 'trigger_pulse_event_args'
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
        @enabled_projects = Set.new
      end

      # Allows triggers of the given project to run on this trigger engine
      # @param project_tag [Symbol]
      def enable_project(project_tag:)
        @enabled_projects << project_tag
      end

      # Disables execution of project's triggers on this trigger engine
      def disable_project(project_tag:)
        @enabled_projects.delete project_tag
      end

      protected

      def read_and_lock_next_due_trigger
        @trigger_repository.read_and_lock_next_due_trigger(due_ts: Time.now.utc, projects: @enabled_projects.to_a)
      end

      def store_and_release_trigger(trigger)
        @trigger_repository.update_and_release_trigger(trigger: trigger)
      end

      def due_triggers?
        @trigger_repository.due_triggers?(due_ts: Time.now.utc, projects: @enabled_projects.to_a)
      end

      def run_cycle(cancellation_token)
        while due_triggers? && !cancellation_token.cancellation_requested?
          trigger = read_and_lock_next_due_trigger
          next if trigger.nil?

          process_trigger trigger
        end
      end

      def process_trigger(trigger)
        outputs = trigger.pulse
        @pipeline_engine.stage_complete(trigger.project_tag, trigger.full_tag, outputs)
      ensure
        store_and_release_trigger trigger
      end
    end
  end
end
