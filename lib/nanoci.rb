require 'yaml'

require 'nanoci/options'
require 'nanoci/project'
require 'nanoci/version'

require 'pp'

##
# Main entry point
class Nanoci
  def self.main(args)
    options = Options.parse(args)
    unless options.project.nil?
      project_src = YAML.load_file options.project
      project = Project.from_hash(project_src)
      pp project
    end
  end
end
