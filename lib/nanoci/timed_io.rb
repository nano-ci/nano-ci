require 'stringio'

class Nanoci
  class TimedIO
    TIME_FORMAT = '[%FT%T.%L%z]'.freeze

    def initialize(stream)
      @stream = stream
    end

    def write(string)
      @stream.write(insert_time(string))
    end

    def write_nonblock(string)
      @stream.write_nonblock(insert_time(string))
    end

    def respond_to?(symbol, include_priv=false)
      @stream.respond_to?(symbol, include_priv)
    end

    private

    def peek(c)
      @stream.seek(-1, IO::SEEK_CUR)
      ch = @stream.getc
      @stream.ungetc(c)
      c == ch
    end

    def insert_time(string)
      time = "#{Time.now.strftime(TIME_FORMAT)} "
      string = string.gsub(/\n.+/, '\n' + time)
      @stream.pos.zero? || peek('\n') ? time + string : string
    end

    def method_missing(method, *args, &block)
      @stream.send(method, *args, &block)
    end
  end
end
