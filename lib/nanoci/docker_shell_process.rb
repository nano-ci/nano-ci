# frozen_string_literal: true

require_relative 'mixins/logger'
require_relative 'shell_process'

module Nanoci
  # [DockerShellProcess] is a class to monitor a command execution in a docker container
  class DockerShellProcess < ShellProcess
    include Mixins::Logger

    class << self
      def run(container, cmd, opts = {})
        process = DockerShellProcess.new(container, cmd, opts)
        process.send(:exec)
        process
      end
    end

    private

    def initialize(container, cmd, opts = {})
      super(cmd, opts)
      @container = container
    end

    def exec
      log.debug { "shell @ container##{@container.id}: \"#{@cmd}\" at \"#{@cwd}\"" }
      output = @container.exec(['sh', '-c', @cmd], 'WorkingDir' => @cwd, env: @env.map { |k, v| "#{k}=#{v}" })
      output[0].each { |line| @stdout.puts line }
      output[1].each { |line| @stderr.puts line }
      @status = output[2]
      log.debug { "shell @ container##{@container.id}: exit code - #{@status}" }
    end
  end
end
