# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/messaging/message'
require 'nanoci/messaging/topic'

RSpec::Matchers.define :a_message_id_eq do |expected|
  match do |actual|
    actual.id == expected
  end
end

RSpec.describe Nanoci::Messaging::Topic do
  it '#initialize sets topic name' do
    topic = Nanoci::Messaging::Topic.new(:test_topic)
    expect(topic.name).to eq :test_topic

    topic = Nanoci::Messaging::Topic.new('new_topic')
    expect(topic.name).to eq :new_topic
  end

  it '#attach attaches a subscription' do
    sub = double(:sub)
    allow(sub).to receive(:id) { :sub }

    topic = Nanoci::Messaging::Topic.new(:top)
    expect(topic.subscriptions).to be_empty

    topic.attach(sub)

    expect(topic.subscriptions).to include sub
  end

  it '#detach detaches a subscription' do
    sub = double(:sub)
    allow(sub).to receive(:id) { :sub }

    topic = Nanoci::Messaging::Topic.new(:top)
    topic.attach(sub)

    expect(topic.subscriptions).to include sub

    topic.detach(sub)

    expect(topic.subscriptions).to be_empty
  end

  it '#publish pushes a message to an attached subscription' do
    msg = Nanoci::Messaging::Message.new
    msg.payload = 'abc'

    sub = double(:sub)
    allow(sub).to receive(:id) { :sub }
    expect(sub).to receive(:push).with(msg)

    topic = Nanoci::Messaging::Topic.new(:top)
    topic.attach(sub)

    topic.publish(msg)
  end

  it '#publish does not pushe a message to a detached subscription' do
    msg = Nanoci::Messaging::Message.new
    msg.payload = 'abc'

    sub = double(:sub)
    allow(sub).to receive(:id) { :sub }
    expect(sub).not_to receive(:push)

    topic = Nanoci::Messaging::Topic.new(:top)
    topic.attach(sub)
    topic.detach(sub)

    topic.publish(msg)
  end

  it '#publish generates unique message id' do
    sub = double(:sub)
    allow(sub).to receive(:id) { :sub }
    expect(sub).to receive(:push).with(a_message_id_eq(0))
    expect(sub).to receive(:push).with(a_message_id_eq(1))

    msg1 = Nanoci::Messaging::Message.new
    msg1.payload = 'abc'

    msg2 = Nanoci::Messaging::Message.new
    msg2.payload = 'def'

    topic = Nanoci::Messaging::Topic.new(:top)
    topic.attach(sub)
    topic.publish(msg1)
    topic.publish(msg2)
  end
end
