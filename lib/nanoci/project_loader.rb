# frozen_string_literal: true

require 'logging'
require 'yaml'

require 'nanoci/artifact'
require 'nanoci/project'
require 'nanoci/repo'
require 'nanoci/triggers/poll_trigger'
require 'nanoci/stage'
require 'nanoci/task'
require 'nanoci/tasks/all'
require 'nanoci/variable'

class Nanoci
  ##
  # ProjectLoader loads project definition from file
  class ProjectLoader
    attr_reader :log

    def initialize
      @log = Logging.logger[self]
    end

    def load(path)
      project_src = YAML.load_file path
      read_project(project_src)
    end

    def read_project(hash)
      hash = sanitize(hash)
      project = Project.new(hash)
      project.repos = read_repos(project, hash, :repos)
      project.stages = read_stages(project, hash, :stages)
      project.variables = read_variables(hash, :variables)
      project
    end

    def read_array(hash, field, map)
      (hash[field] || []).map { |x| map.call(x) }.reject(&:nil?)
    end

    def read_repos(project, hash, field)
      items = read_array(hash, field, ->(h) { read_repo(project, h) })
      Hash[items.map { |v| [v.tag, v] }]
    end

    def read_repo(project, hash)
      type = hash[:type]
      repo_class = Repo.types[type]
      if repo_class.nil?
        log.warn "Unknown repo type #{type}"
        return nil
      end
      repo = repo_class.new(hash)
      repo.triggers = read_triggers(repo, project, hash, :triggers)
      repo
    end

    def read_triggers(repo, project, hash, field)
      read_array(hash, field, ->(h) { read_trigger(repo, project, h) })
    end

    def read_trigger(repo, project, hash)
      type = hash[:type]
      trigger_class = Trigger.types[type]
      if trigger_class.nil?
        log.warn "Unknown trigger type #{type}"
        return nil
      end
      trigger_class.new(repo, project, hash)
    end

    def read_stages(project, hash, field)
      read_array(hash, field, ->(h) { read_stage(project, h) })
    end

    def read_stage(project, hash)
      stage = Stage.new(hash)
      stage.jobs = read_jobs(project, hash, :jobs)
      stage
    end

    def read_jobs(project, hash, field)
      read_array(hash, field, ->(h) { read_job(project, h) })
    end

    def read_job(project, hash)
      job = Job.new(project, hash)
      job.tasks = read_tasks(hash, :tasks)
      job.artifacts = read_artifacts(hash, :artfacts)
      job
    end

    def read_tasks(hash, field)
      read_array(hash, field, method(:read_task))
    end

    def read_task(hash)
      type = hash[:type]
      task_class = Task.types[type]
      if task_class.nil?
        log.warn "Unknown task type #{type}"
        return nil
      end
      task_class.new(hash)
    end

    def read_artifacts(hash, field)
      read_array(hash, field, method(:read_artifact))
    end

    def read_artifact(hash)
      Artifact.new(hash)
    end

    def read_variables(hash, field)
      items = read_array(hash, field, method(:read_variable))
      Hash[items.map { |v| [v.tag, v] }]
    end

    def read_variable(hash)
      Variable.new(sanitize(hash))
    end

    def sanitize(value)
      if value.is_a? Hash
        value.map { |k, v| [k.to_sym, sanitize(v)] }.to_h
      elsif value.is_a? Array
        value.map { |x| sanitize(x) }
      else
        value
      end
    end
  end
end
