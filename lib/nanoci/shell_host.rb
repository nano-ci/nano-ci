# frozen_string_literal: true

require 'fileutils'

require_relative 'mixins/logger'
require_relative 'shell_process'

module Nanoci
  # [ShellHost] is a class that executes shell commands on host
  class ShellHost
    include Mixins::Logger

    # Executes passed command line
    # @param cmd [String] command line to execute
    # @param work_dir [String] working directory
    # @param env [Hash] environment variables
    # @return [Nanoci::ShellProcess] shell process to monitor progress
    def run(cmd, work_dir, env: nil)
      raise ArgumentError, 'work_dir must be absolute path' unless File.absolute_path?(work_dir)

      log.debug { "shell: \"#{cmd}\" at \"#{work_dir}\"" }
      ensure_work_dir(work_dir)
      tool = ShellProcess.run(cmd, cwd: work_dir, env: env)
      log.debug { "shell: exit code - #{tool.status}" }
      tool
    end

    protected

    def ensure_work_dir(work_dir)
      FileUtils.mkpath work_dir
    end
  end
end
