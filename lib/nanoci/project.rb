# frozen_string_literal: true

require 'logging'

require 'nanoci'
require 'nanoci/definition/variable_definition'
require 'nanoci/repo'
require 'nanoci/variable'

class Nanoci
  ##
  # Represents a project in nano-ci
  class Project
    attr_reader :stages
    attr_reader :repos
    attr_reader :variables
    attr_reader :reporters

    attr_reader :definition

    def name
      definition.name
    end

    def tag
      definition.tag
    end

    def build_number
      variables['buildNumber']&.value || 1
    end

    def build_number=(value)
      var = variables['buildNumber']
      var = Variable.new(tag: 'buildNumber', value: 1) if var.nil?
      var.value = value
      variables['buildNumber'] = var
    end

    # Initializes new instance of [Project]
    # @param definition [ProjectDefinition]
    def initialize(definition)
      @log = Logging.logger[self]
      @definition = definition
      @repos = read_repos(definition.repos)
      @stages = read_stages(definition.stages)
      @variables = read_variables(definition.variables)
      # @reporters = read_reporters(definition.reporters)
    end

    def state
      {
        tag: tag,
        repos: repos.map { |k, v| [k, v.state] }.to_h,
        variables: variables.map { |k, v| [k, v.memento]}.to_h
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

    ##
    # Reads repos from array of repo definitions
    # @param repo_definition [Array<RepoDefinition>]
    # @return [Array<Repo>]
    def read_repos(repo_definitions)
      repo_definitions.map { |r| [r.tag, Repo.resolve(r.type).new(r)] }.to_h
    end

    ##
    # Reads repos from array of repo definitions
    # @param repo_definition [Array<RepoDefinition>]
    # @return [Array<Repo>]
    def read_stages(stage_definition)
      []
    end

    # Reads repos from array of repo definitions
    # @param repo_definition [Array<RepoDefinition>]
    # @return [Array<Repo>]
    def read_variables(variable_definition)
      variable_definition.map { |d| [d.tag, Variable.new(d)] }.to_h
    end
  end
end
