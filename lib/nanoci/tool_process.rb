# frozen_string_literal: true

require 'open3'
require 'stringio'

require 'nanoci/mixins/logger'
require 'nanoci/tool_error'

module Nanoci
  # Class to run external tool and capture stdout and stderr
  class ToolProcess
    include Nanoci::Mixins::Logger

    attr_reader :pid, :stdin, :stdout, :stderr, :cmd, :env

    # Runs a new process
    # @param cmd [String] command to execute
    # @param opts [Hash]  options
    # @option opts [IO] :stdin stream to pass to stdin of the new process
    # @option opts [IO] :stdout stream to receive the output of the new process
    # @option opts [IO] :stderr stream to receive the error output of the new process
    # @option opts [String] :chdir the working directory of the new process
    # @option opts [Hash<Symbol, String>] :env environment variables for the new process
    def self.run(cmd, **kwargs)
      process = ToolProcess.new(cmd, kwargs)
      process.run
      process
    end

    # Initializes new instance of [ToolProcess]
    # @param cmd [String] command to execute
    # @param opts [Hash]  options
    # @option opts [IO] :stdin stream to pass to stdin of the new process
    # @option opts [IO] :stdout stream to receive the output of the new process
    # @option opts [IO] :stderr stream to receive the error output of the new process
    # @option opts [String] :chdir the working directory of the new process
    # @option opts [Hash<Symbol, String>] :env environment variables for the new process
    def initialize(cmd, stdin: nil, stdout: nil, stderr: nil, chdir: '.', env: {})
      @stdin = stdin || StringIO.new
      @stdout = stdout || StringIO.new
      @stderr = stderr || StringIO.new
      @chdir = chdir || '.'
      @env = env || {}
      @cmd = cmd
    end

    def run
      log.debug("running #{@cmd} at #{@chdir}")
      log.debug("env:\n#{@env}")
      options = {
        chdir: @chdir,
        unsetenv_others: true
      }
      p_in, p_out, p_err, @wait_thr = Open3.popen3(@env, @cmd, options)
      connect([
                { from: @stdin, to: p_in },
                { from: p_out, to: @stdout },
                { from: p_err, to: @stderr }
              ])
    end

    def wait
      @wait_thr.join
      @connect_threads.each(&:join)
      return self if status_code.zero?

      case status_code
      when 127
        raise ToolError.new(@cmd, status_code, "command not found: #{@cmd}")
      else
        raise ToolError.new(@cmd, status_code, error)
      end
    end

    def output
      read_stringio(@stdout)
    end

    def error
      read_stringio(@stderr)
    end

    def status_code
      @wait_thr.value.exitstatus
    end

    private

    def read_stringio(io)
      pos = io.pos
      io.rewind
      result = io.readlines.map(&:chomp)
      io.seek(pos)
      result.join("\n")
    end

    def connect(streams)
      @connect_threads = streams.map { |p| connect_pair(p[:from], p[:to]) }
    end

    def connect_pair(from, to)
      Thread.new(from, to) do |f, t|
        loop do
          buf = read(f)
          break unless buf
          break unless write(buf, t)
        end
      end
    end

    def read(from)
      from.read_nonblock(1024)
    rescue IO::WaitReadable
      IO.select([from])
      retry
    rescue EOFError
      false
    end

    def write(buf, to)
      to.write(buf)
      true
    rescue IO::WaitWritable
      IO.select(nil, [to])
      retry
    rescue EOFError
      false
    end
  end
end
