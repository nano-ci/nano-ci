# frozen_string_literal: true

require 'spec_helper'
require 'nanoci/plugins/git/repo_git'

RSpec.describe 'nano-ci plugin git' do
  it 'registers RepoGit' do
    expect(Nanoci.resources.get('repo:git')).to eq Nanoci::Plugins::Git::RepoGit
  end
end
