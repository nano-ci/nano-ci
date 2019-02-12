# frozen_string_literal: true

require 'open3'
require 'stringio'

require 'nanoci/mixins/logger'
require 'nanoci/tool_error'
require 'nanoci/variable'

module Nanoci
  ##
  # Class to run external tool and capture stdout and stderr
  class ToolProcess
    include Nanoci::Mixins::Logger

    attr_reader :stdin
    attr_reader :stdout
    attr_reader :stderr
    attr_reader :cmd
    attr_reader :env

    attr_reader :pid

    # Runs a new process
    # @param cmd [String] command to execute
    # @param opts [Hash]  options
    # @option opts [IO] :stdin stream to pass to stdin of the new process
    # @option opts [IO] :stdout stream to receive the output of the new process
    # @option opts [IO] :stderr stream to receive the error output of the new process
    # @option opts [String] :chdir the working directory of the new process
    # @option opts [Hash<Symbol, String>] :env environment variables for the new process
    # @option opts [Hash<Symbol, String>] :vars variables to use for expanding
    def self.run(cmd, opts)
      process = ToolProcess.new(cmd, opts)
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
    # @option opts [Hash<Symbol, String>] :vars variables to use for expanding
    def initialize(cmd, opts = {})
      @stdin = opts[:stdin] || StringIO.new
      @stdout = opts[:stdout] || StringIO.new
      @stderr = opts[:stderr] || StringIO.new
      @chdir = opts.fetch(:chdir, '.')
      @env = expand_env(opts.fetch(:env, {}), opts.fetch(:vars, {}))
      @cmd = cmd
      @throw_non_zero_exit_code = opts.fetch(:throw_non_zero_exit_code, true)
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

    # Expands env variables using hash of variables
    # @param env [Hash<Symbol, String>]
    # @param vars [Hash<Symbol, String>]
    def expand_env(env, vars)
      env = Bundler::original_env.merge(env)
      env.transform_values { |v| Variable.expand_string(v, vars) }
    end
  end
end
