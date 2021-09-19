# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/definition/repo_definition'
require 'nanoci/plugins/git/repo_git'

RSpec.describe Nanoci::Plugins::Git::RepoGit do
  it 'adds required capabilitiy "tools.git"' do
    repo_def = Nanoci::Definition::RepoDefinition.new(
      tag: 'repo',
      type: 'git',
      src: 'http://example.com'
    )
    repo = Nanoci::Plugins::Git::RepoGit.new(repo_def)
    expect(repo.required_agent_capabilities).to include 'tools.git'
  end
end
