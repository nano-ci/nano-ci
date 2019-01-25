# frozen_string_literal: true

require 'nanoci/definition/job_definition'
require 'nanoci/task'
require 'nanoci/tasks/all'

module Nanoci
  # A job is a collection of tasks to run actions and produce artifacts
  class Job
    attr_accessor :tag
    attr_accessor :tasks

    # Initializes new instance of [Job]
    # @param definition [JobDefinition]
    def initialize(definition)
      @tag = definition.tag
      @tasks = read_tasks(definition.tasks)
    end

    # Returns required agent capabilities to run the job.
    # @return [Set<Symbol>]
    def required_agent_capabilities(build)
      @tasks.map { |t| t.required_agent_capabilities(build) }.reduce(:merge)
    end

    private

    def read_tasks(task_definitions)
      task_definitions.map { |d| Task.resolve(d.type).new(d) }
    end
  end
end
