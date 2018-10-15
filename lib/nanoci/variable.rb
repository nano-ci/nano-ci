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
        until (match = PATTERN.match(result)).nil?
          var_reference = match[1].to_sym
          raise "Cycle in expanding variable #{tag}" if var_reference == tag
          sub = variables[var_reference] || ''
          sub_value = sub.is_a?(Variable) ? sub.value : sub
          result = value.sub(match[0], sub_value)
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
