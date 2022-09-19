# frozen_string_literal: true

require 'nanoci/core/project'

module Nanoci
  # Centralized object to store, retrieve, and update projects
  # Default implementation backed by in-memory store
  class ProjectRepository
    def initialize
      @store = []
    end

    # Adds a project to the repository
    # @param project [Nanoci::Core::Project]
    # @return [Nanoci::Core::Project]
    def add(project)
      raise ArgumentError unless project.is_a? Core::Project
      raise ArgumentError if duplicate_project? project.tag

      @store.push(project)
      project
    end

    def save(project)
      raise ArgumentError, 'project is not tracked by the repository' unless @store.include? project
    end

    def save_stage(project, _stage)
      raise ArgumentError, 'project is not tracked by the repository' unless @store.include? project
    end

    # Finds a project by tag
    # @param tag [Symbol]
    # @return [Nanoci::Core::Project|Nil] project; nil if project is not found
    def find_by_tag(tag)
      @store.select { |e| e.tag == tag }.first
    end

    private

    def duplicate_project?(tag)
      @store.any? { |e| e.tag == tag }
    end
  end
end
