class Nanoci
  ##
  # A variable is an object to hold string value to use in task configuration
  # Task may reference a variable using syntax ${var_name}
  class Variable
    attr_accessor :tag
    attr_accessor :value

    def initialize
      @tag = nil
      @value = nil
    end
  end
end
