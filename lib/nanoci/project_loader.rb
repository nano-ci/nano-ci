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
      project = Project.new(hash)
      project.repos = read_repos(project, hash, 'repos')
      project.stages = read_stages(hash, 'stages')
      project.variables = read_variables(hash, 'variables')
      project
    end

    def read_array(hash, field, map)
      (hash[field] || []).map { |x| map.call(x) }
    end

    def read_repos(project, hash, field)
      Hash[read_array(hash, field, ->(h) { read_repo(project, h) }).map {|v| [v.tag, v]}]
    end

    def read_repo(project, hash)
      type = hash['type']
      repo_class = Repo.types[type]
      if repo_class.nil?
        log.warn "Unknown repo type #{type}"
        return
      end
      repo = repo_class.new(hash)
      repo.triggers = read_triggers(repo, project, hash, 'triggers')
      repo
    end

    def read_triggers(repo, project, hash, field)
      read_array(hash, field, ->(h) { read_trigger(repo, project, h) } )
    end

    def read_trigger(repo, project, hash)
      type = hash['type']
      trigger_class = Trigger.types[type]
      if trigger_class.nil?
        log.warn "Unknown trigger type #{type}"
        return
      end
      trigger_class.new(repo, project, hash)
    end

    def read_stages(hash, field)
      read_array(hash, field, method(:read_stage))
    end

    def read_stage(hash)
      stage = Stage.new(hash)
      stage.jobs = read_jobs(hash, 'jobs')
      stage
    end

    def read_jobs(hash, field)
      read_array(hash, field, method(:read_job))
    end

    def read_job(hash)
      job = Job.new(hash)
      job.tasks = read_tasks(hash, 'tasks')
      job.artifacts = read_artifacts(hash, 'artfacts')
      job
    end

    def read_tasks(hash, field)
      read_array(hash, field, method(:read_task))
    end

    def read_task(hash)
      type = hash['type']
      task_class = Task.types[type]
      if task_class.nil?
        log.warn "Unknown task type #{type}"
        return
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
      Hash[read_array(hash, field, method(:read_variable)).map {|v| [v.tag, v]}]
    end

    def read_variable(hash)
      Variable.new(hash)
    end
  end
end
