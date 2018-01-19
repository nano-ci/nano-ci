require 'logging'

layout = Logging.layouts.pattern(
  :pattern      => '[%d] %-5l [%c] %m\n',
  :date_pattern => '%Y-%m-%d %H:%M:%S'
)

Logging.appenders.stdout(
  :layout => layout
)

root = Logging.logger.root
root.add_appenders(
  Logging.appenders.stdout
)
