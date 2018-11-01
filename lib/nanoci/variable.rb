# frozen_string_literal: true

require 'nanoci/definition/variable_definition'

class Nanoci
  ##
  # A variable is an object to hold string value to use in task configuration
  # Task may reference a variable using syntax ${var_name}
  class Variable
    attr_accessor :tag
    attr_accessor :value

    PATTERN = /\$\{([^\}]+)\}/

    # Initializes new instance of Variable
    # @param definition [VariableDefinition]
    def initialize(definition)
      @tag = definition.tag
      @value = definition.value
    end

    # Expands variable value, i.e. substitutes var references with var values
    # @param variables [Hash<Symbol, Variable|String>]
    # @return [String] Expanded value of the variable
    def expand(variables)
      result = value
      if result.is_a? String
        result = expand_string(result, variables)
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

    private

    def expand_string(str, variables)
      expanded_variables = Set[]
      until (match = PATTERN.match(str)).nil?
        var_reference = match[1].to_sym
        raise "Cycle in expanding variable #{tag}" if expanded_variables.include? var_reference
        expanded_variables.add(var_reference)
        sub = variables[var_reference] || ''
        sub_value = sub.is_a?(Variable) ? sub.value : sub
        str = str.sub(match[0], sub_value)
      end
      str
    end
  end
end
