# frozen_string_literal: true

module Nanoci
  module Core
    # Enables DSL to get a reference to repo in job block
    class ProjectRepoLocator
      # Initializes new instance of [ProjectRepoLocator]
      def initialize(project)
        @project = project
      end

      def method_missing(method_name, *_, &_)
        @project.find_repo(method_name)
      end

      def respond_to_missing?(method_name)
        !@project.find_repo(method_name).nil?
      end
    end
  end
end
