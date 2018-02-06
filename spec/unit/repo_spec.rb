require 'spec_helper'

require 'nanoci/repo'

RSpec.describe Nanoci::Repo do
  it 'saves tag from src' do
    repo = Nanoci::Repo.new('tag' => 'repo-tag')
    expect(repo.tag).to eq 'repo-tag'
  end

  it 'saves type from src' do
    repo = Nanoci::Repo.new('type' => 'repo-tag')
    expect(repo.type).to eq 'repo-tag'
  end

  it 'set type to "unknown" it type is not set in src' do
    repo = Nanoci::Repo.new
    expect(repo.type).to eq 'unknown'
  end

  it 'saves src from src' do
    repo = Nanoci::Repo.new('src' => 'http://example.com/repo/test.git')
    expect(repo.src).to eq 'http://example.com/repo/test.git'
  end

  it 'saves auth from src' do
    repo = Nanoci::Repo.new('auth' => 'username:password')
    expect(repo.auth).to eq 'username:password'
  end

  it 'detect_changes returns true' do
    repo = Nanoci::Repo.new
    expect(repo.detect_changes({})).to be true
  end

  it 'current_commit returns empty string' do
    repo = Nanoci::Repo.new
    expect(repo.current_commit).to eq ''
  end

  it 'state returns tag' do
    repo = Nanoci::Repo.new('tag' => 'repo-tag')
    expect(repo.state[:tag]).to eq 'repo-tag'
  end

  it 'state returns current_commit' do
    class TestRepo < Nanoci::Repo
      def initialize(*args)
        super
        @current_commit = 'abc'
      end
    end

    repo = TestRepo.new('tag' => 'repo-tag')
    expect(repo.state[:current_commit]).to eq 'abc'
  end

  it 'state restures current_commit' do
    repo = Nanoci::Repo.new('tag' => 'repo-tag')
    state = { tag: 'repo-tag', current_commit: 'abc' }
    repo.state = state
    expect(repo.current_commit).to eq 'abc'
  end
end
