require 'nanoci/options'
require 'nanoci/version'

require 'pp'

##
# Main entry point
class Nanoci
  def self.main(args)
    options = Options.parse(args)
    pp options
  end
end
