# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/messaging/message'

RSpec.describe Nanoci::Messaging::Message do
  it '#initialize creates #attributes hash' do
    msg = Nanoci::Messaging::Message.new
    expect(msg.attributes).to be_instance_of(Hash)
  end

  it '#payload= accepts nil value' do
    msg = Nanoci::Messaging::Message.new
    expect { msg.payload = nil }.not_to raise_error
  end

  it '#payload returns nil value' do
    msg = Nanoci::Messaging::Message.new
    msg.payload = nil
    expect(msg.payload).to be_nil
  end

  it '#payload= accepts String value' do
    msg = Nanoci::Messaging::Message.new
    expect { msg.payload = 'test string' }.not_to raise_error
  end

  it '#payload_str returns String value' do
    msg = Nanoci::Messaging::Message.new
    msg.payload = 'test string'
    expect(msg.payload_str).to eql('test string')
  end

  it '#payload= accepts byte Array' do
    msg = Nanoci::Messaging::Message.new
    expect { msg.payload = [0, 1, 2, 255] }.not_to raise_error
  end

  it '#payload returns Array value' do
    msg = Nanoci::Messaging::Message.new
    msg.payload = [0, 1, 2, 255]
    expect(msg.payload).to eql([0, 1, 2, 255])
  end

  it '#payload= raise ArgumentException on not supported value' do
    msg = Nanoci::Messaging::Message.new
    expect { msg.payload = {} }.to raise_error(ArgumentError)
  end

  it '#payload= raise ArgumentException on non-byte Array value' do
    msg = Nanoci::Messaging::Message.new
    expect { msg.payload = [-1] }.to raise_error(ArgumentError)
    expect { msg.payload = [256] }.to raise_error(ArgumentError)
  end
end
