# frozen_string_literal: true

module Nanoci
  module Events
    # Event about reporing job state
    class ReportJobStateEvent < Event
      # Gets project tag
      # @return [Symbol]
      attr_reader :project_tag

      # Gets job tag
      # @return [Symbol]
      attr_reader :job_tag

      # Gets an agent tag
      # @return [Symbol]
      attr_reader :agent_tag

      # Gets a job state
      # @return [Nanoci::Build::State]
      attr_reader :state

      # Initializes new instance of [ReportJobStateEvent]
      # @param project_tag [Symbol]
      # @param job_tag [Symbol]
      # @param agent_tag [Symbol]
      # @param state [Nanoci::Build::State]
      def initialize(project_tag, job_tag, agent_tag, state)
        @project_tag = project_tag
        @job_tag = job_tag
        @agent_tag = agent_tag
        @state = state
      end
    end
  end
end
