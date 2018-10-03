# frozen_string_literal: true

require 'logging'
require 'stringio'

require 'nanoci/build_stage'
require 'nanoci/common_vars'
require 'nanoci/timed_io'

class Nanoci
  ##
  # Build is the type that represents one integration cycle for a project
  class Build # rubocop:disable Metrics/ClassLength
    ##
    # Build state enumeration
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

      def log
        Logging.logger[self]
      end

      def run(project, trigger, env_variables, env)
        variables = expand_variables(project.variables, env_variables)

        refresh_repos(project, env)

        build = Build.new(project, trigger, variables, env)
        build&.current_stage&.jobs&.each { |j| j.state = State::QUEUED }

        log_build(build)

        build
      end

      def refresh_repos(project, env)
        project.repos.values.each do |r|
          env = env.clone
          env[CommonVars::WORKDIR] = r.repo_cache(env)
          r.update(env)
          r.current_commit = r.tip_of_tree(r.branch, env)
        end
      end

      def log_build(build)
        log.info "build #{build.tag} started at #{build.start_time}"
        log.info "commits:\n #{build.commits}"
        log.info "variables: \n #{build.variables}"
      end

      def expand_variables(project_variables, env_variables)
        all_variables = project_variables.merge(env_variables)
        all_variables.map { |k, v| [k, v.expand(all_variables)] }.to_h
      end
    end

    attr_accessor :project
    attr_accessor :trigger
    attr_accessor :start_time
    attr_accessor :end_time
    attr_accessor :stages
    attr_accessor :current_stage
    attr_accessor :variables
    attr_reader   :output

    def tag
      "#{@project.tag}-#{number}"
    end

    def tests
      @tests ||= []
    end

    def number
      variables['buildNumber'] || 0
    end

    private def number=(number)
      variables['buildNumber'] = number
    end

    def commits
      @commits ||= Hash[@project.repos.map { |t, r| [t, r.current_commit] }]
    end

    def state
      current_stage&.state || State::UNKNOWN
    end

    def complete
      @output.close
      @end_time = Time.now
      project.reporters.each { |b| b.report(self) }
    end

    def memento # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      {
        tag: tag,
        project: project.tag,
        start_time: start_time,
        end_time: end_time,
        state: State.to_sym(state),
        stages: Hash[stages.map { |s| [s.tag, s.memento] }],
        current_stage: current_stage.tag,
        tests: tests.map(&:memento),
        commits: commits.clone,
        variables: variables.clone
      }
    end

    private

    def initialize(project, trigger, variables, env)
      @project = project
      @trigger = trigger
      @variables = variables
      @start_time = Time.now
      self.number = number + 1
      setup_stages(@project)
      env['build_data_dir'] = File.join(env['build_data_dir'], tag)
      setup_output(env, tag)
    end

    def setup_stages(project)
      @stages = project.stages.map { |x| BuildStage.new(x) }
      @current_stage = @stages.select { |x| x.jobs.any? }.first
    end

    def setup_output(env, tag)
      FileUtils.mkpath(env['build_data_dir'])
      output_file_name = File.join(env['build_data_dir'], "#{tag}.log")
      @output = TimedIO.create_path(output_file_name)
    end
  end
end
