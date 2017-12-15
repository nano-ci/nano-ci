require 'nanoci/trigger'

class Nanoci
  class Triggers
    class PollTrigger < Trigger
      attr_accessor :interval
      attr_accessor :schedule

      def initialize(hash = {})
        super(hash)

        @interval = hash['interval']
        @schedule = hash['schedule']
      end
    end
end
end
