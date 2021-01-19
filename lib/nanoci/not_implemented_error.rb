# frozen_string_literal: true

module Nanoci
  # Error that's thrown when a requested method is not implemented.
  class NotImplementedError < StandardError
    def initialize(class_name, method_name)
      super("#{class_name}::#{method_name} is not implemented")
    end
  end
end
