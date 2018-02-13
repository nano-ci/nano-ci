require 'nanoci/plugin'
require 'nanoci/plugins/rspec/task_test_rspec'
require 'nanoci/task'

class Nanoci
  class Plugins
    class RSpec
      class PluginRSpec < Plugin
        def initialize
          Task.types['test-rspec'] = TaskTestRSpec
        end
      end

      Plugin.plugins.push PluginRSpec
    end
  end
end
