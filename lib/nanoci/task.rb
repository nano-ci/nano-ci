class Nanoci
  class Task
    attr_accessor :type

    @types = {}

    def self.types
      @types
    end

    def initialize(hash = {})
      @type = hash['type']
    end

    def required_agent_capabilities(_project)
      Set[]
    end
  end
end
