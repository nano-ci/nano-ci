# frozen_string_literal: true

require 'logging'

layout = Logging.layouts.pattern(
  pattern: '[%d] %-5l [%c] %m\n',
  date_pattern: '%Y-%m-%d %H:%M:%S'
)

Logging.appenders.stdout(
  layout: layout
)

root = Logging.logger.root
root.level = :info
root.add_appenders(
  Logging.appenders.stdout
)
