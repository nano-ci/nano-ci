# frozen_string_literal: true

require 'nanoci/dsl/project_dsl'

module Nanoci
  module DSL
    # ScriptDSL is the class responsible to read and parse Ruby-based pipeline script
    class ScriptDSL
      def initialize
        @projects = {}
      end

      attr_reader :projects

      class << self
        def from_string(str)
          script = ScriptDSL.new
          script.instance_eval(str)
          script
        end
      end

      def project(tag, name, &block)
        raise "project #{tag} is missing definition block" if block.nil?

        pr = ProjectDSL.new(tag, name)
        projects[tag] = pr
        pr.instance_eval(&block)
      end
    end
  end
end
