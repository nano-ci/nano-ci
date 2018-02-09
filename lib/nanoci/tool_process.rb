require 'open3'
require 'stringio'

require 'nanoci/tool_error'

class Nanoci
  class ToolProcess
    attr_reader :stdin
    attr_reader :stdout
    attr_reader :stderr

    attr_reader :pid

    def self.run(cmd, opts)
      process = ToolProcess.new(cmd, opts)
      process.run
      process
    end

    def initialize(cmd, opts = {})
      @stdin = opts[:stdin] || StringIO.new
      @stdout = opts[:stdout] || StringIO.new
      @stderr = opts[:stderr] || StringIO.new
      @cmd = cmd
    end

    def run
      p_in, p_out, p_err, @wait_thr = Open3.popen3(@cmd)
      connect([
                { from: @stdin, to: p_in },
                { from: p_out, to: @stdout },
                { from: p_err, to: @stderr }
              ])
    end

    def wait
      @wait_thr.join
      @connect_threads.each(&:join)
      raise ToolError.new(@cmd, status_code, error) unless status_code.zero?
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
      return from.read_nonblock(1024)
    rescue IO::WaitReadable
      IO.select([from])
      retry
    rescue EOFError
      return false
    end

    def write(buf, to)
      to.write(buf)
      return true
    rescue IO::WaitWritable
      IO.select(nil, [to])
      retry
    rescue EOFError
      return false
    end
  end
end
