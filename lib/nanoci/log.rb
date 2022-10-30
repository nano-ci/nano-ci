# frozen_string_literal: true

require 'intake'

Intake[:root].level = :debug

TIMESTAMP_FORMAT = '%Y-%m-%dT%H:%M:%S.%6N'
stdout_sink = Intake::IOSink.new($stdout)
formatter = ->(e) { "#{e.level} #{e.timestamp.strftime(TIMESTAMP_FORMAT)} [#{e.logger_name}]: #{e.message}" }
stdout_sink.formatter = formatter
Intake.add_sink stdout_sink
