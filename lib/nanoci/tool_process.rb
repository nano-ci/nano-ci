require 'open4'
require 'stringio'

class Nanoci
  class ToolProcess
    include Open4
    attr_reader :stdin
    attr_reader :stdout
    attr_reader :stderr

    def initialize(cmd, opts = {})
      @stdin = opts[:stdin] || StringIO.new
      @stdout = opts[:stdout] || StringIO.new
      @stderr = opts[:stderr] || StringIO.new

      @status = spawn(cmd,
                      'stdin' => @stdin,
                      'stdout' => @stdout,
                      'stderr' => @stderr,
                      'raise' => false
                     )
    end

    def pid
      @status.pin
    end

    def output
      pos = @stdout.pos
      @stdout.rewind
      result = @stdout.readlines
      @stdout.seek(pos)
      result
    end
  end
end
