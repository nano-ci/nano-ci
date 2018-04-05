# frozen_string_literal: true

class Nanoci
  ##
  # Base class for nano-ci build task
  class Task
    class << self
      def types
        @types ||= {}
      end
    end

    attr_accessor :workdir

    def initialize(hash = {})
      @type = hash[:type]
      @workdir = hash[:workdir] || '.'
    end

    def required_agent_capabilities(_project)
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
