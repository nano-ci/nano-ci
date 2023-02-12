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
      # @param stage_complete_topic [Nanoci::Messaging::Topic]
      def initialize(trigger_repository, stage_complete_topic)
        @trigger_repository = trigger_repository
        @stage_complete_topic = stage_complete_topic
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

      def tick(cancellation_token)
        return if cancellation_token.cancellation_requested?

        trigger = read_and_lock_next_due_trigger
        process_trigger(trigger) unless trigger.nil?
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

      # @param trigger [Nanoci::Core::trigger]
      def process_trigger(trigger)
        project_tag = trigger.project_tag
        trigger_tag = trigger.full_tag
        outputs = trigger.pulse
        dtr = trigger.downstream_trigger_rule
        message = Messages::StageCompleteMessage.new(project_tag, trigger_tag, outputs, dtr)
        @stage_complete_topic.publish(message)
      ensure
        store_and_release_trigger trigger
      end
    end
  end
end
