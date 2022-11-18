# frozen_string_literal: true

require 'nanoci/plugin_host'
require 'nanoci/plugins/plugin_base'

require_relative 'ruby_command'

module Nanoci
  module Plugins
    module Ruby
      # [Nanoci::Plugins::Ruby::RubyPlugin] provides acceess to ruby command.
      class RubyPlugin < Nanoci::Plugins::PluginBase
        def augment(extension_point)
          super

          extension_point.add_command(:ruby, method(:ruby).to_proc)
        end

        private

        # Gets an instance of git command configured for the specified repo.
        def ruby(command_host, project)
          RubyCommand.new(command_host, project)
        end
      end
    end
  end
end

Nanoci::PluginHost.register_plugin(:'command.ruby', Nanoci::Plugins::Ruby::RubyPlugin)
