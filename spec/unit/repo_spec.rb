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
end
