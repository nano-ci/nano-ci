# frozen_string_literal: true

require 'nanoci/common_vars'
require 'nanoci/mixins/provides'

module Nanoci
  # Base class for nano-ci build task
  class Task
    extend Mixins::Provides

    class << self
      # Registers a provider of a resource
      # @param tag [String] tag to identify the provider
      def provides(tag)
        super("task:#{tag}")
      end

      # Returns the provider of a resource
      # @param tag [String] tag to identify the provider
      # @return [Class] class implementing the resource
      def resolve(tag)
        super("task:#{tag}")
      end
    end

    # The definition of the task
    # @return [TaskDefinition]
    attr_reader :definition

    # Task type
    # @return [Symbol]
    def type
      definition.type
    end

    # Working directory for the task. Relative to project working directory
    # @return [String]
    def workdir
      definition.workdir
    end

    # Project the task is part of
    # @return [Project]
    attr_reader :project

    # Initializes new instance of [Task]
    # @param definition [TaskDefinition]
    def initialize(definition, project)
      @definition = definition
      @project = project
    end

    def required_agent_capabilities
      Set[]
    end

    def execute(build, workdir)
      task_workdir = File.join(workdir, build.tag, workdir)
      FileUtils.mkdir_p(task_workdir) unless Dir.exist? task_workdir
      execute_imp(build, workdir)
    end

    def execute_imp(build, workdir); end
  end
end
