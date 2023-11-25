# frozen_string_literal: true

require 'nanoci/plugins/plugin_base'

require_relative 'docker_command'

module Nanoci
  module Plugins
    module Docker
      # [Nanoci::Plugins::Git::Docker] provides acceess to docker command.
      class DockerPlugin < Nanoci::Plugins::PluginBase
        def augment(extension_point)
          super

          extension_point.add_command(:docker, method(:docker).to_proc)
        end

        private

        # Gets an instance of git command configured for the specified repo.
        def docker(command_host, project)
          DockerCommand.new(command_host, project)
        end
      end
    end
  end
end

Nanoci::PluginHost.register_plugin(:'command.docker', Nanoci::Plugins::Docker::DockerPlugin)
