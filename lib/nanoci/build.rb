require 'nanoci/build_stage'

class Nanoci
  class Build
    module State
      UNKNOWN = 0
      QUEUED = 1
      RUNNING = 2
      ABORTED = 3
      FAILED = 4
      COMPLETED = 5
    end

    class << self
      def run(project, trigger, env_variables)
        variables = expand_variables(project.variables, env_variables)
        Build.new(project, trigger, variables)
      end

      attr_accessor :project_build_numbers

      def expand_variables(project_variables, env_variables)
        all_variables = project_variables.merge(env_variables)
        all_variables.map { |k, v| [k, v.expand(all_variables)] }.to_h
      end

      def next_number(project_tag)
        self.project_build_numbers ||= {}
        current_number = self.project_build_numbers[project_tag] || 0
        current_number += 1
        self.project_build_numbers[project_tag] = current_number
        current_number
      end
    end

    attr_accessor :tag
    attr_accessor :project
    attr_accessor :trigger
    attr_accessor :start_time
    attr_accessor :end_time
    attr_accessor :current_stage
    attr_accessor :commits
    attr_accessor :variables

    def number
      variables['buildNumber']
    end

    private def number=(number)
      variables['buildNumber'] = number
    end

    def state
      current_stage&.state || State::UNKNOWN
    end

    private

    def initialize(project, trigger, variables)
      @project = project
      @trigger = trigger
      @variables = variables
      @start_time = Time.now
      self.number = Build.next_number(@project.tag)
      @tag = "#{@project.tag}-#{number}"
      @current_stage = BuildStage.new(@project.stages[0])
      @commits = @project.repos.map { |r| [r.tag, r.current_commit] }.to_h
    end
  end
end
