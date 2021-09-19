# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/artifact'

RSpec.describe Nanoci::Artifact do
  let(:src) do
    {
      'tag' => 'tag',
      'path' => 'abc/def/',
      'pattern' => 'abc.*def'
    }
  end

  it 'reads tag from source' do
    artifact = Nanoci::Artifact.new(src)
    expect(artifact.tag).to eq('tag')
  end

  it 'reads path from source' do
    artifact = Nanoci::Artifact.new(src)
    expect(artifact.path).to eq('abc/def/')
  end

  it 'reads pattern from source' do
    artifact = Nanoci::Artifact.new(src)
    expect(artifact.pattern).not_to be_nil
    expect(artifact.pattern.source).to eq('abc.*def')
  end
end
