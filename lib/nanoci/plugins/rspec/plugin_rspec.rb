# frozen_string_literal: true

require 'nanoci/plugin'
require 'nanoci/plugins/rspec/task_test_rspec'
require 'nanoci/task'

class Nanoci
  class Plugins
    # Entry class for RSpec plugin
    class RSpec
      # RSpec plugin class
      class PluginRSpec < Plugin
        def initialize
          Task.types['test-rspec'] = TaskTestRSpec
        end
      end

      Plugin.plugins.push PluginRSpec
    end
  end
end
