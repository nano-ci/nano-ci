require 'yaml'

require 'nanoci/options'
require 'nanoci/project_loader'

require 'pp'

##
# Main entry point
class Nanoci
  def self.main(args)
    options = Options.parse(args)
    project = ProjectLoader.load(options.project) unless options.project.nil?
    pp project
  end
end
