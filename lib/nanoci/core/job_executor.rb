# frozen_string_literal: true

require 'nanoci/mixins/logger'
require 'nanoci/not_implemented_error'
require 'nanoci/system/event'

require_relative 'job'

module Nanoci
  module Core
    JobRun = Struct.new('JobRun', :job, :state, :inputs, :prev_inputs, :outputs)

    # Executes jobs
    class JobExecutor
      include Nanoci::Mixins::Logger

      # Initializes new instance of [Nanoci::Core::JobExecutor]
      # @param plugin_host [Nanoci::PluginHost]
      def initialize(plugin_host)
        @observers = []
        @plugin_host = plugin_host
        @running_jobs = {}
        @completed_jobs = []
      end

      # Scheduled execution of a job
      # @param job [Nanoci::Core::Job]
      # @param inputs [Hash]
      # @param prev_inputs [Hash]
      def schedule_job_execution(job, inputs, prev_inputs)
        raise ArgumentError, "job #{job} is already running" if job_running?(job)

        job_run = JobRun.new(job: job, state: Job::State::RUNNING, inputs: inputs, prev_inputs: prev_inputs)
        @running_jobs[job.full_tag] = job_run
      end

      def schedule_hook_execution(_project, _stage, _job, _inputs, _prev_inputs)
        nil
      end

      # @param job [Nanoci::Core::Job]
      def job_running?(job) = @running_jobs.key?(job.full_tag)

      def completed_jobs? = @completed_jobs.any?

      def pull_completed_job = @completed_jobs.pop

      protected

      def job_succeeded(job, outputs)
        job_run = @running_jobs[job.full_tag]
        job_run.state = Job::State::SUCCESSFUL
        job_run.outputs = outputs
        @completed_jobs.unshift(@running_jobs.delete(job.full_tag))
      end

      # Job failure handler
      # @param job [Nanoci::Core::Job]
      # @param outputs [Hash]
      # @param error [StandardError]
      def job_failed(job, _outputs, error)
        log.error(error: error) { "failed to execute job <#{job.project}.#{job.stage}.#{job}>" }

        job_run = @running_jobs[job.full_tag]
        job_run.state = Job::State::FAILED
        @completed_jobs.unshift(@running_jobs.delete(job.full_tag))

        execute_after_failure_hook(job)
      end

      def execute_after_failure_hook(job)
        after_failure_hook = job.stage.hook_after_failure
        return if after_failure_hook.nil?

        log.debug { "job #{job} has hook <after_failure>. running the hook..." }
        execute_hook(job, "#{job.tag}_hook_after_failure".to_sym, after_failure_hook)
      end

      def execute_hook(job, hook_job_tag, hook_body)
        hook_job = Job.new(tag: hook_job_tag, body: hook_body, work_dir: job.work_dir, env: job.env)
        schedule_hook_execution(job.project, job.stage, hook_job, {}, {})
      end
    end
  end
end
