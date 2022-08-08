# frozen_string_literal: true

require 'nanoci/dsl/project_dsl'

module Nanoci
  module DSL
    # ScriptDSL is the class responsible to read and parse Ruby-based pipeline script
    class ScriptDSL
      def initialize
        @projects = []
      end

      # Gets array of projects read from the script
      # @return [Array<Nanoci::DSL::ProjectDSL>]
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
        pr.instance_eval(&block)
        @projects.push(pr)
      end
    end
  end
end
