require 'logging'

root = Logging.logger.root
root.add_appenders(
  Logging.appenders.stdout
)
