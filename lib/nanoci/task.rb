# frozen_string_literal: true

require 'nanoci/mixins/provides'

class Nanoci
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

    # Task type
    # @return [Symbol]
    attr_accessor :type

    # Working directory for the task. Relative to project working directory
    # @return [String]
    attr_accessor :workdir

    # Initializes new instance of [Task]
    # @param definition [TaskDefinition]
    def initialize(definition, _project)
      @type = definition.type
      @workdir = definition.workdir
    end

    def required_agent_capabilities
      Set[]
    end

    def execute(build, env)
      task_workdir = File.join(build.workdir(env), workdir)
      FileUtils.mkdir_p(task_workdir) unless Dir.exist? task_workdir
      Dir.chdir(task_workdir) do
        execute_imp(build, env)
      end
    end

    def execute_imp(build, env); end
  end
end
