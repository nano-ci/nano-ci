# frozen_string_literal: true

require 'docker-api'

require_relative 'mixins/logger'

require_relative 'shell_host'
require_relative 'docker_shell_process'

module Nanoci
  # [DockerShellHost] is a class that executes shell commands in docker container
  class DockerShellHost < ShellHost
    include Mixins::Logger

    # Initializes new instance of [DockerShellHost]
    # @param job [Nanoci::Core::Job] Job that will be executed in this shell host
    def initialize(job)
      super()
      @name = container_name(job)
      @container = Docker::Container.create(
        name: @name,
        'Cmd' => ['/bin/sh'],
        'Image' => job.docker_image,
        'Tty' => true
      )
      @container.start
      log.info { "container container[id = #{@container.id}, name = #{@name}] is running" }
    end

    def dispose
      log.info { "disposing container container[id = #{@container.id}, name = #{@name}]" }
      @container.stop
      log.info { "container container[id = #{@container.id}, name = #{@name}] is stopped" }
      @container.delete(force: true)
      log.info { "container container[id = #{@container.id}, name = #{@name}] is disposed" }
    end

    protected

    def ensure_work_dir(work_dir)
      @container.exec(['mkdir', '-p', work_dir])
    end

    def execute_shell(cmd, work_dir, env: nil)
      DockerShellProcess.run(@container, cmd, cwd: work_dir, env: env)
    end

    private

    # @param job [Nanoci::Core::Job]
    def container_name(job)
      "nanoci-#{job.project.tag}-#{job.stage.tag}-#{job.tag}-#{Time.now.to_i}"
    end
  end
end
