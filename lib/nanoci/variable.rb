# frozen_string_literal: true

class Nanoci
  ##
  # A variable is an object to hold string value to use in task configuration
  # Task may reference a variable using syntax ${var_name}
  class Variable
    attr_accessor :tag
    attr_accessor :value

    PATTERN = /\$\{([^\}]+)\}/

    def initialize(hash = {})
      @tag = hash[:tag]
      @value = hash[:value]
    end

    def expand(variables)
      result = value
      if result.is_a? String
        until (match = PATTERN.match(result)).nil?
          raise "Cycle in expanding variable #{tag}" if match[1] == tag
          result = value.sub(match[0], variables[match[1]]&.value || '')
        end
      end
      result
    end

    def memento
      {
        tag: tag,
        value: value
      }
    end

    def memento=(value)
      raise "tag #{tag} does not match state tag #{value[:tag]}" \
        unless tag == value[:tag]
      self.value = value[:value]
    end
  end
end
