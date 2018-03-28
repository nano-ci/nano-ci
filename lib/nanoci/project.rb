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
        repos: Hash[repos.map { |k, v| [k, v.state] }]
      }
    end

    def state=(value)
      raise "tag #{tag} does not match state tag #{value[:tag]}" \
        unless tag == value[:tag]
      value[:repos].each do |k, v|
        repo = repos[k]
        if repo.nil?
          @log.warn "repo definition #{k} does not exist"
        else
          repo.state = v
        end
      end
    end
  end
end
