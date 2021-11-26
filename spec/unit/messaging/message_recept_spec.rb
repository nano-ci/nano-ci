# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/messaging/message'
require 'nanoci/messaging/message_receipt'

RSpec.describe Nanoci::Messaging::MessageReceipt do
  it '#initialize sets message' do
    msg = Nanoci::Messaging::Message.new
    msg.id = '123'

    receipt = Nanoci::Messaging::MessageReceipt.new(msg, nil)
    expect(receipt.message).to eq msg
  end

  it '#ack calls @subscription.ack with message id' do
    sub = double(:sub)
    expect(sub).to receive(:ack).with('123')

    msg = Nanoci::Messaging::Message.new
    msg.id = '123'

    receipt = Nanoci::Messaging::MessageReceipt.new(msg, sub)
    receipt.ack
  end

  it '#nack calls @subscription.nack with message id' do
    sub = double(:sub)
    expect(sub).to receive(:nack).with('123')

    msg = Nanoci::Messaging::Message.new
    msg.id = '123'

    receipt = Nanoci::Messaging::MessageReceipt.new(msg, sub)
    receipt.nack
  end
end
