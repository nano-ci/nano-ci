# frozen_string_literal: true

require 'nanoci/definition/job_definition'
require 'nanoci/task'

class Nanoci
  # A job is a collection of tasks to run actions and produce artifacts
  class Job
    attr_accessor :tag
    attr_accessor :tasks

    # Initializes new instance of [Job]
    # @param definition [JobDefinition]
    def initialize(definition, project)
      @tag = definition.tag
      @tasks = read_tasks(definition.tasks, project)
    end

    # Returns required agent capabilities to run the job.
    # @return [Set<Symbol>]
    def required_agent_capabilities
      @tasks.map(&:required_agent_capabilities).reduce(:merge)
    end

    private

    def read_tasks(task_definitions, project)
      task_definitions.map { |d| Task.resolve(d.type).new(d, project) }
    end
  end
end
