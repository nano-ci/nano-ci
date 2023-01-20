# frozen_string_literal: true

require 'stringio'

module Nanoci
  # Executes a command in shell. Optionally, provides IO-like interface to stdin, stdout, and stderr
  class ShellCmd
    READ_TIMEOUT = 600
    READ_WAIT_TIME = 0.01
    READ_BUFFER_SIZE = 4096

    attr_reader :status

    # Initializes new instance of [ShellCmd]
    # @param cmd [String] command to execute
    # @param opts [Hash] options
    # @option opts [String] :input input string to pass to child process' stdin. Ignored if :live_stdin is set
    # @option opts [IO] :live_stdin optional IO stream with input to pass to child process
    # @option opts [IO] :live_stdout optional IO object to receive live output of the child process
    # @option opts [IO] :live_stderr optional IO object to receive live stderr output of the child process
    # @option opts [String] :cwd the current directory of the child process
    # @option opts [Hash] :env environment variables
    # @option opts [Integer] :read_timeout timeout in seconds to wait for output before interrupting the child process
    def initialize(cmd, opts = {})
      @cmd = cmd
      @live_stdin = opts[:live_stdin]
      @live_stdout = opts[:live_stdout]
      @live_stderr = opts[:live_stderr]
      @input = @live_stdin.nil? ? opts[:input] : nil
      @cwd = opts[:cwd]
      @env = (opts[:env] || {})&.transform_keys!(&:to_s)&.transform_values(&:to_s)

      @stdout = StringIO.new
      @stderr = StringIO.new
    end

    def stdout = @stdout.string

    def stderr = @stderr.string

    def run
      setup_ipc

      @status = nil

      @pid = Process.spawn(@env, @cmd, spawn_options)

      if @input.nil?
        @stdin_pipe[1].close if @live_stdin.nil?
      else
        (@stdin_pipe[1] << input).close
      end

      @open_io = [@live_stdin, @stdout_pipe[0], @stderr_pipe[0]].compact
      drive_io
    end

    private

    def drive_io
      until @status
        ready = IO.select(@open_io, nil, nil, READ_WAIT_TIME)
        if ready
          drive_ready_io(ready)

          yield if block_given?
        end
        try_finalize
      end
    end

    def drive_ready_io(ready)
      pipe_to_pipe(@stdout_pipe[0], @stdout, @live_stdout) if ready[0].include?(@stdout_pipe[0])
      pipe_to_pipe(@stderr_pipe[0], @stderr, @live_stderr) if ready[0].include?(@stderr_pipe[0])
      pipe_to_pipe(@live_stdin, @stdin_pipe[1]) if ready[0].include?(@live_stdin)
    end

    def pipe_to_pipe(from, to, live = nil)
      while (chunk = from.read_nonblock(READ_BUFFER_SIZE))
        to << chunk
        live << chunk if live
      end
    rescue Errno::EAGAIN
      # Try again later, no data yet
    rescue EOFError
      @open_io.delete(from)
    end

    def try_finalize
      results = Process.waitpid2(@pid, Process::WNOHANG)
      @status = results.last if results
    end

    def setup_ipc
      @stdin_pipe = IO.pipe
      @stdout_pipe = IO.pipe
      @stderr_pipe = IO.pipe
    end

    def spawn_options
      options = {
        in: @stdin_pipe[0],
        out: @stdout_pipe[1],
        err: @stderr_pipe[1],
        unsetenv_others: true
      }
      options[:chdir] = @cwd unless @cwd.nil?
      options
    end
  end
end
