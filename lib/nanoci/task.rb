class Nanoci
  class Task
    attr_accessor :type

    def initialize(hash = {})
      @type = hash['type']
    end
  end
end
