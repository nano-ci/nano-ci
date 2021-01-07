# frozen_string_literal: true

module Nanoci
  class NotImplementedError < StandardError
    def initialize(class_name, method_name)
      super("#{class_name}::#{method_name} is not implemented")
    end
  end
end
