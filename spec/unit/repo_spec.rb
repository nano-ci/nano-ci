# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/repo'

RSpec.describe Nanoci::Repo do
  it 'reads tag from src' do
    repo = Nanoci::Repo.new(tag: 'repo-tag',
                            type: 'repo',
                            uri: 'https://example.com')
    expect(repo.tag).to eq :'repo-tag'
  end

  it 'reads type from src' do
    repo = Nanoci::Repo.new(tag: 'repo-tag',
                            type: 'repo',
                            uri: 'https://example.com')
    expect(repo.type).to eq :repo
  end

  it 'reads src from src' do
    repo = Nanoci::Repo.new(tag: 'repo-tag',
                            type: 'repo',
                            uri: 'http://example.com/repo/test.git')
    expect(repo.uri).to eq 'http://example.com/repo/test.git'
  end

  it 'reads auth from src' do
    repo = Nanoci::Repo.new(tag: 'repo-tag',
                            type: 'repo',
                            uri: 'http://example.com/repo/test.git',
                            auth: 'username:password')
    expect(repo.auth).to eq 'username:password'
  end

  it 'state returns tag' do
    repo = Nanoci::Repo.new(tag: 'repo-tag',
                            type: 'repo',
                            uri: 'http://example.com/repo/test.git')
    expect(repo.state[:tag]).to eq :'repo-tag'
  end
end
