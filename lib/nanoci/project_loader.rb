require 'yaml'

require 'nanoci/artifact'
require 'nanoci/project'
require 'nanoci/repo'
require 'nanoci/triggers/poll_trigger'
require 'nanoci/stage'
require 'nanoci/task'
require 'nanoci/variable'

class Nanoci
  class ProjectLoader
    def self.load(path)
      project_src = YAML.load_file path
      read_project(project_src)
    end

    def self.read_project(hash)
      project = Project.new(hash)
      project.repos = read_repos(hash, 'repos')
      project.stages = read_stages(hash, 'stages')
      project.variables = read_variables(hash, 'variables')
      project
    end

    def self.read_array(hash, field, map)
      (hash[field] || []).map { |x| map.call(x) }
    end

    def self.read_repos(hash, field)
      read_array(hash, field, method(:read_repo))
    end

    def self.read_repo(hash)
      repo = Repo.new(hash)
      repo.triggers = read_triggers(hash, 'triggers')
      repo
    end

    def self.read_triggers(hash, field)
      read_array(hash, field, method(:read_trigger))
    end

    def self.read_trigger(hash)
      type = hash['type']
      case type
      when 'poll'
        Triggers::PollTrigger.new(hash)
      else
        raise "Unknown trigger type #{type}"
      end
    end

    def self.read_stages(hash, field)
      read_array(hash, field, method(:read_stage))
    end

    def self.read_stage(hash)
      stage = Stage.new(hash)
      stage.jobs = read_jobs(hash, 'jobs')
      stage
    end

    def self.read_jobs(hash, field)
      read_array(hash, field, method(:read_job))
    end

    def self.read_job(hash)
      job = Job.new(hash)
      job.tasks = read_tasks(hash, 'tasks')
      job.artifacts = read_artifacts(hash, 'artfacts')
      job
    end

    def self.read_tasks(hash, field)
      read_array(hash, field, method(:read_task))
    end

    def self.read_task(hash)
      Task.new(hash)
    end

    def self.read_artifacts(hash, field)
      read_array(hash, field, method(:read_artifact))
    end

    def self.read_artifact(hash)
      Artifact.new(hash)
    end

    def self.read_variables(hash, field)
      read_array(hash, field, method(:read_variable))
    end

    def self.read_variable(hash)
      Variable.new(hash)
    end
  end
end
