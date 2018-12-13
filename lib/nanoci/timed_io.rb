# frozen_string_literal: true

require 'stringio'

module Nanoci
  ##
  # TimedIO is the text stream class that appends current time to each line
  class TimedIO
    TIME_FORMAT = '[%FT%T.%L%z]'

    class << self
      def create_path(path)
        TimedIO.new(File.open(path, 'w+'))
      end
    end

    def initialize(stream)
      @stream = stream
    end

    def write(string)
      @stream.write(insert_time(string))
    end

    def write_nonblock(string)
      @stream.write_nonblock(insert_time(string))
    end

    def respond_to?(symbol, include_priv = false)
      @stream.respond_to?(symbol, include_priv)
    end

    private

    def peek(char)
      @stream.seek(-1, IO::SEEK_CUR)
      ch = @stream.getc
      @stream.ungetc(ch)
      char == ch
    end

    def insert_time(string)
      time = "#{Time.now.strftime(TIME_FORMAT)} "
      string = string.gsub(/\n.+/, "\n" + time)
      @stream.pos.zero? || peek("\n") ? time + string : string
    end

    def method_missing(method, *args, &block)
      if @stream.respond_to?(method)
        @stream.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(symbol, include_all)
      super
    end
  end
end
