# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/trigger'

RSpec.describe Nanoci::Trigger do
  it '#full_tag returns "trigger.tag"' do
    trigger = Nanoci::Trigger.new(tag: :trigger_tag, type: :test)
    expect(trigger.full_tag).to eq :'trigger.trigger_tag'
  end
end
