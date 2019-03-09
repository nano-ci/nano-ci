# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/event_engine'

RSpec.describe Nanoci::EventEngine do
  it 'calls callback on known event type' do
    handler = double('handler')
    expect(handler).to receive(:handle_event)
    engine = Nanoci::EventEngine.new(
      test_type: handler.method(:handle_event)
    )
    engine.run
    engine.enqueue_task(Nanoci::Event.new(:test_type))
    engine.stop.wait!
  end

  it 'calls callback with event data' do
    handler = double('handler')
    data = :abc
    expect(handler).to receive(:handle_event).with(data)
    engine = Nanoci::EventEngine.new(
      test_type: handler.method(:handle_event)
    )
    engine.run
    engine.enqueue_task(Nanoci::Event.new(:test_type, data))
    engine.stop.wait!
  end

  it 'does not raise exeption if handler is not registered' do
    engine = Nanoci::EventEngine.new({})
    future = engine.run
    engine.enqueue_task(Nanoci::Event.new(:unknown))
    engine.stop
    future.wait!(5)
    expect(future.reason).to be_nil
    log_lines = @log_output.readlines
    expect(log_lines).to include "ERROR  Nanoci::EventEngine : <RuntimeError> unknown event class unknown\n"
  end
end
