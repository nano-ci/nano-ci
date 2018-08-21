# frozen_string_literal: true

require 'spec_helper'

require 'nanoci/plugin'
require 'nanoci/plugins/git/plugin_git'
require 'nanoci/plugins/git/repo_git'
require 'nanoci/repo'

RSpec.describe 'nano-ci plugin git' do
  it 'registers RepoGit' do
    expect(Nanoci.resources.get('repo:git')).to eq Nanoci::Plugins::Git::RepoGit
  end
end
