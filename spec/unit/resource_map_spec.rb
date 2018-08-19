# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/resource_map'

RSpec.describe Nanoci::ResourceMap do
  it 'gets and sets a resource' do
    rm = Nanoci::ResourceMap.new
    rm.set('test resource', Object)
    resource = rm.get('test resource')
    expect(resource).to eq Object
  end
end
