# frozen_string_literal: true

module Nanoci
  # A job is a collection of tasks to run actions and produce artifacts
  class Job
    # @return [Symbol]
    attr_accessor :tag

    # @return [Proc]
    attr_accessor :body

    # Initializes new instance of [Job]
    # @param src [Hash]
    def initialize(src)
      @tag = src[:tag]
      @body = src[:block]
    end
  end
end
