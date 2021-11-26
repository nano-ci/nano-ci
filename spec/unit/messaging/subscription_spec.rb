# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/messaging/message'
require 'nanoci/messaging/subscription'

RSpec.describe Nanoci::Messaging::Subscription do
  it '#initializes sets a subscription name' do
    sub = Nanoci::Messaging::Subscription.new(:abc)
    expect(sub.name).to eq :abc

    sub = Nanoci::Messaging::Subscription.new('abc')
    expect(sub.name).to eq :abc
  end

  it '#pull returns nil if empty' do
    sub = Nanoci::Messaging::Subscription.new(:abc)

    expect(sub.pull).to be_nil
  end

  it '#pull returns available message' do
    sub = Nanoci::Messaging::Subscription.new(:abc)
    msg = Nanoci::Messaging::Message.new
    msg.id = '1'
    msg.payload = 'abc message'
    sub.push(msg)

    msg_receipt = sub.pull

    expect(msg_receipt).not_to be_nil
    expect(msg_receipt.message.id).to eq '1'
    expect(msg_receipt.message.payload_str).to eq 'abc message'
  end

  it '#pull does not return leased message' do
    sub = Nanoci::Messaging::Subscription.new(:abc)
    msg = Nanoci::Messaging::Message.new
    msg.id = '1'
    msg.payload = 'abc message'
    sub.push(msg)

    msg_receipt = sub.pull

    msg_receipt_nil = sub.pull

    expect(msg_receipt).not_to be_nil
    expect(msg_receipt_nil).to be_nil
  end

  it '#pull returns leased message after nack' do
    sub = Nanoci::Messaging::Subscription.new(:abc)
    msg = Nanoci::Messaging::Message.new
    msg.id = '1'
    msg.payload = 'abc message'
    sub.push(msg)

    msg_receipt = sub.pull
    msg_receipt.nack

    msg_receipt_nack = sub.pull

    expect(msg_receipt).not_to be_nil
    expect(msg_receipt_nack).not_to be_nil
    expect(msg_receipt_nack.message.id).to eq '1'
    expect(msg_receipt_nack.message.payload_str).to eq 'abc message'
  end

  it '#pull does not return leased message after ack' do
    sub = Nanoci::Messaging::Subscription.new(:abc)
    msg = Nanoci::Messaging::Message.new
    msg.id = '1'
    msg.payload = 'abc message'
    sub.push(msg)

    msg_receipt = sub.pull
    msg_receipt.ack

    msg_receipt_nil = sub.pull

    expect(msg_receipt).not_to be_nil
    expect(msg_receipt_nil).to be_nil
  end
end
