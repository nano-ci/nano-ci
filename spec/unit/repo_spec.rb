# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/definition/repo_definition'
require 'nanoci/repo'

RSpec.describe Nanoci::Repo do
  it 'reads tag from src' do
    repo_def = Nanoci::Definition::RepoDefinition.new(
      tag: 'repo-tag',
      type: 'repo',
      src: 'https://example.com'
    )
    repo = Nanoci::Repo.new(repo_def)
    expect(repo.tag).to eq :'repo-tag'
  end

  it 'reads type from src' do
    repo_def = Nanoci::Definition::RepoDefinition.new(
      tag: 'repo-tag',
      type: 'repo',
      src: 'https://example.com'
    )
    repo = Nanoci::Repo.new(repo_def)
    expect(repo.type).to eq :repo
  end

  it 'reads src from src' do
    repo_def = Nanoci::Definition::RepoDefinition.new(
      tag: 'repo-tag',
      type: 'repo',
      src: 'http://example.com/repo/test.git'
    )
    repo = Nanoci::Repo.new(repo_def)
    expect(repo.src).to eq 'http://example.com/repo/test.git'
  end

  it 'reads auth from src' do
    repo_def = Nanoci::Definition::RepoDefinition.new(
      tag: 'repo-tag',
      type: 'repo',
      src: 'http://example.com/repo/test.git',
      auth: 'username:password'
    )
    repo = Nanoci::Repo.new(repo_def)
    expect(repo.auth).to eq 'username:password'
  end

  it 'reads main from src' do
    repo_def = Nanoci::Definition::RepoDefinition.new(
      tag: 'repo-tag',
      type: 'repo',
      src: 'http://example.com/repo/test.git',
      main: true
    )
    repo = Nanoci::Repo.new(repo_def)
    expect(repo.main).to be true
  end

  it 'main default value is false' do
    repo_def = Nanoci::Definition::RepoDefinition.new(
      tag: 'repo-tag',
      type: 'repo',
      src: 'http://example.com/repo/test.git'
    )
    repo = Nanoci::Repo.new(repo_def)
    expect(repo.main).to be false
  end

  it 'detect_changes returns true' do
    repo_def = Nanoci::Definition::RepoDefinition.new(
      tag: 'repo-tag',
      type: 'repo',
      src: 'http://example.com/repo/test.git'
    )
    repo = Nanoci::Repo.new(repo_def)
    expect(repo.changes?({})).to be true
  end

  it 'current_commit returns empty string' do
    repo_def = Nanoci::Definition::RepoDefinition.new(
      tag: 'repo-tag',
      type: 'repo',
      src: 'http://example.com/repo/test.git'
    )
    repo = Nanoci::Repo.new(repo_def)
    expect(repo.current_commit).to eq ''
  end

  it 'state returns tag' do
    repo_def = Nanoci::Definition::RepoDefinition.new(
      tag: 'repo-tag',
      type: 'repo',
      src: 'http://example.com/repo/test.git'
    )
    repo = Nanoci::Repo.new(repo_def)
    expect(repo.state[:tag]).to eq :'repo-tag'
  end

  it 'state returns current_commit' do
    repo_def = Nanoci::Definition::RepoDefinition.new(
      tag: 'repo-tag',
      type: 'repo',
      src: 'http://example.com/repo/test.git'
    )
    repo = Nanoci::Repo.new(repo_def)
    repo.current_commit = 'abc'
    expect(repo.state[:current_commit]).to eq 'abc'
  end

  it 'state restures current_commit' do
    repo_def = Nanoci::Definition::RepoDefinition.new(
      tag: 'repo-tag',
      type: 'repo',
      src: 'http://example.com/repo/test.git'
    )
    repo = Nanoci::Repo.new(repo_def)
    state = { tag: 'repo-tag', current_commit: 'abc' }
    repo.state = state
    expect(repo.current_commit).to eq 'abc'
  end
end
