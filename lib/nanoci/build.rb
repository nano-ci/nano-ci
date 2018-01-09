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
      attr_accessor :project_build_numbers

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
      State.UNKNOWN if current_stage.nil?
      current_stage.jobs.select(&:state).min
    end

    def initialize(project, trigger, env_variables)
      @project = project
      @trigger = trigger
      @variables = expand_variables(@project.variables, env_variables)
    end

    def run
      self.start_time = Time.now
      number = Build.next_number(project.tag)
      self.tag = "#{project.tag}-#{number}"
      self.current_stage = BuildStage.new(project.stages[0])
      self.commits = project.repos.map { |r| [r.tag, r.current_commit] }.to_h
    end

    private

    def expand_variables(project_variables, env_variables)
      all_variables = project_variables + env_variables
      all_variables.map { |v| v.expand(all_variables) }
    end
  end
end
