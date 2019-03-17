# frozen_string_literal: true

require 'nanoci/definition/variable_definition'

module Nanoci
  ##
  # A variable is an object to hold string value to use in task configuration
  # Task may reference a variable using syntax ${var_name}
  class Variable
    PATTERN = /\$\{([^\}]+)\}/

    class << self
      # Expands a string using hash of variables
      # @param str [String]
      # @param vars [Hash<Symbol, Variable|String>]
      def expand_string(str, vars)
        expanded_vars = Set[]
        until (match = PATTERN.match(str)).nil?
          var_tag = match[1].to_sym
          raise "Cycle in expanding variable #{tag}" if expanded_vars.include? var_tag
          expanded_vars.add(var_tag)
          sub_value = vars.fetch(var_tag, '').to_s
          str = str.sub(match[0], sub_value)
        end
        str
      end
    end

    attr_accessor :tag
    attr_accessor :value

    # @overload initialize(definition)
    #   Inializes new instance of Variable using VariableDefinition
    #   @param definition [VariableDefinition] Variable definition
    # @overload initialize(key, value)
    #   Initializes new instance of Variable using key and value
    #   @param key [Symbol] Variable tag
    #   @param value [Object] Variable value
    def initialize(definition, value = nil)
      case definition
      when Definition::VariableDefinition
        @tag = definition.tag
        @value = definition.value
      when Symbol
        @tag = definition
        @value = value
      else
        raise 'unsupported arguments'
      end
    end

    # Expands variable value, i.e. substitutes var references with var values
    # @param variables [Hash<Symbol, Variable|String>]
    # @return [String] Expanded value of the variable
    def expand(variables)
      case value
      when String
        Variable.expand_string(result, variables)
      else
        value
      end
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

    def to_s
      value
    end

    def inspect
      "<Variable #{tag}: #{value}>"
    end

    def ==(other)
      case other
      when Variable
        @tag == other.tag && @value == other.value
      else
        @value == other
      end
    end
  end
end
