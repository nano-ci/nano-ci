class Nanoci
  class AgentCapability
    attr_accessor :name
    attr_accessor :value

    def initialize(name, value)
      @name = name
      @value = value
    end

    def eql?(other)
      @name == other.name && @value == other.value
    end

    alias_method :==, :eql?
  end
end
