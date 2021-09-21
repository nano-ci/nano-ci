# frozen_string_literal: true

require 'logging'

require 'nanoci'
require 'nanoci/pipeline'
require 'nanoci/repo'

module Nanoci
  # Represents a project in nano-ci
  class Project
    attr_reader :name, :tag, :plugins, :reporters

    # @return [Hash{Symbol => Repo}]
    attr_reader :repos

    # @return [Nanoci::Pipeline]
    attr_reader :pipeline

    # Initializes new instance of [Project]
    # @param source [Hash] Hash with data from DSL
    def initialize(name:, tag:, repos: [], pipeline: {}, plugins: {})
      @log = Logging.logger[self]
      @name = name
      @tag = tag
      @repos = read_repos(repos)
      @pipeline = read_pipeline(pipeline)
      @plugins = plugins
      @reporters = []
    end

    def state
      {
        tag: tag,
        repos: repos.transform_values(&:state),
        variables: variables.transform_values(&:memento)
      }
    end

    def state=(value)
      raise "tag #{tag} does not match state tag #{value[:tag]}" \
        unless tag == value[:tag]

      restore_repos(value[:repos]) unless value[:repos].nil?
      restore_variables(value[:variables]) unless value[:variables].nil?
    end

    def restore_repos(repos_memento)
      repos_memento.each do |k, v|
        repo = repos[k.to_sym]
        if repo.nil?
          @log.warn "repo definition #{k} does not exist"
        else
          repo.state = v
        end
      end
    end

    def restore_variables(variables_memento)
      variables_memento.each do |k, v|
        variable = variables[k]
        if variable.nil?
          variable_definition = Nanoci::Definition::VariableDefinition.new(v)
          variable = Variable.new(variable_definition)
          variables[variable.tag] = variable
        else
          variable.memento = v
        end
      end
    end

    # Reads repos from array of repo definitions
    # @param src [Array<Hash>]
    # @return [Array<Repo>]
    def read_repos(src)
      src.to_h { |s| [s[:tag], Repo.new(**s)] }
    end

    # Reads pipeline from src
    # @param src [Hash]
    # @return [Nanoci::Pipeline]
    def read_pipeline(src)
      Pipeline.new(src, self)
    end
  end
end
