require 'logging'
require 'stringio'

require 'nanoci/build_stage'
require 'nanoci/timed_io'

class Nanoci
  class Build
    module State
      UNKNOWN = 0
      QUEUED = 1
      RUNNING = 2
      ABORTED = 3
      FAILED = 4
      COMPLETED = 5

      @mapping = {
        UNKNOWN => :unknown,
        QUEUED => :queued,
        RUNNING => :running,
        ABORTED => :aborted,
        FAILED => :failed,
        COMPLETED => :completed
      }

      def self.to_sym(val)
        @mapping[val] || val
      end
    end

    class << self
      def run(project, trigger, env_variables, env)
        log = Logging.logger[self]
        variables = expand_variables(project.variables, env_variables)

        project.repos.values.each do |r|
          r.in_repo_cache(env) do
            r.update(env)
            r.current_commit = r.tip_of_tree(r.branch, env)
          end
        end

        build = Build.new(project, trigger, variables, env)
        build.current_stage.jobs.each { |j| j.state = State::QUEUED } unless build.current_stage.nil?

        log.info "build #{build.tag} started at #{build.start_time}"
        log.info "commits:\n #{build.commits}"
        log.info "variables: \n #{build.variables}"

        build
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
    attr_accessor :stages
    attr_accessor :current_stage
    attr_accessor :commits
    attr_accessor :variables
    attr_reader   :output

    def number
      variables['buildNumber']
    end

    private def number=(number)
      variables['buildNumber'] = number
    end

    def state
      current_stage&.state || State::UNKNOWN
    end

    def workdir(env)
      File.join(env['workdir'], tag)
    end

    def complete
      @output.close
      @end_time = Time.now
    end

    def memento
      {
        tag: tag,
        project: project.tag,
        start_time: start_time,
        end_time: end_time,
        state: State.to_sym(state),
        stages: Hash[stages.map { |s| [s.tag, s.memento] }],
        current_stage: current_stage.tag,
        commits: commits.clone,
        variables: variables.clone
      }
    end

    private

    def initialize(project, trigger, variables, env)
      @log = Logging.logger[self]
      @project = project
      @trigger = trigger
      @variables = variables
      @start_time = Time.now
      self.number = Build.next_number(@project.tag)
      @tag = "#{@project.tag}-#{number}"
      setup_stages(@project)
      @commits = Hash[@project.repos
                              .map { |t, r| [t, r.current_commit] }]

      logdir = env['logdir']
      FileUtils.mkdir_p(logdir) unless Dir.exist? logdir
      @output = TimedIO.new(File.open(File.join(logdir, "#{@tag}.log"), "w+"))
    end

    def setup_stages(project)
      @stages = project.stages.map { |x| BuildStage.new(x) }
      @current_stage = @stages.select { |x| x.jobs.any? }.first
    end
  end
end
