class Nanoci
  ##
  # A variable is an object to hold string value to use in task configuration
  # Task may reference a variable using syntax ${var_name}
  class Variable
    attr_accessor :tag
    attr_accessor :value

    PATTERN = /\$\{([^\}]+)\}/

    def initialize(hash = {})
      @tag = hash['tag']
      @value = hash['value']
    end

    def expand(variables)
      result = value
      until (match = PATTERN.match(result)).nil?
        raise "Cycle in expanding variable #{tag}" if match[1] == tag
        result = value.sub(match[0], variables[match[1]]&.value || '')
      end
      result
    end
  end
end
