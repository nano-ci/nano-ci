# frozen_string_literal: true

require 'logging'

require 'nanoci'

class Nanoci
  ##
  # Represents a project in nano-ci
  class Project
    attr_accessor :name
    attr_accessor :tag
    attr_accessor :stages

    attr_reader :repos

    def repos=(value)
      raise 'value is not a Hash' unless value.is_a? Hash
      @repos = value
    end

    attr_reader :variables

    def variables=(value)
      raise 'value is not a Hash' unless value.is_a? Hash
      @variables = value
    end

    def build_number
      variables['buildNumber']&.value || 1
    end

    def build_number=(value)
      var = variables['buildNumber']
      var = Variable.new('tag' => 'buildNumber', 'value' => 1) if var.nil?
      var.value = value
      variables['buildNumber'] = var
    end

    def initialize(hash = {})
      @log = Logging.logger[self]
      @name = hash['name']
      @tag = hash['tag']
      @repos = {}
      @stages = []
      @variables = {}
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
      restore_repos(value[:repos])
      restore_variables(value[:variables])
    end

    def restore_repos(repos_memento)
      repos_memento.each do |k, v|
        repo = repos[k]
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
          @log.warn "variable definition #{k} does not exist"
        else
          variable.memento = v
        end
      end
    end
  end
end
