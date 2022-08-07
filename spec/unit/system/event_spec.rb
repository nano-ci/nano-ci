# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Nanoci::System::Event do
  it '#attach attaches a handler and returns subscription token' do
    event = Nanoci::System::Event.new
    sender = nil
    event_args = nil
    token = event.attach do |s, e|
      sender = s
      event_args = e
    end

    event.invoke(self, :args)

    expect(token).not_to be_nil
    expect(sender).to be self
    expect(event_args).to be :args
  end

  it '#detach detaches a handler' do
    event = Nanoci::System::Event.new
    sender = nil
    event_args = nil
    token = event.attach do |s, e|
      sender = s
      event_args = e
    end
    event.detach(token)

    event.invoke(self, :args)

    expect(sender).to be_nil
    expect(event_args).to be_nil
  end
end
