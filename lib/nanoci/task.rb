class Nanoci
  class Task
    attr_accessor :type

    def initialize
      @type = nil
    end

    def self.from_hash(hash)
      task = Task.new
      task.type = hash['type']
      task
    end
  end
end
