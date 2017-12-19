require 'eventmachine'
require 'yaml'

require 'nanoci/options'
require 'nanoci/plugin_loader'
require 'nanoci/project_loader'

require 'pp'

##
# Main entry point
class Nanoci
  def self.main(args)
    options = Options.parse(args)

    PluginLoader.load(options.plugins_path)

    project = ProjectLoader.load(options.project) unless options.project.nil?

    EventMachine.run do
      project.repos.each do |repo|
        repo.triggers.each do |trigger|
          trigger.run(repo, project)
        end
      end
    end
  end
end
