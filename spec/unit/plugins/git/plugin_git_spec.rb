require 'spec_helper'

require 'nanoci/plugin'
require 'nanoci/plugins/git/plugin_git'
require 'nanoci/plugins/git/repo_git'
require 'nanoci/repo'

RSpec.describe Nanoci::Plugins::Git::PluginGit do
  it 'registers itself' do
    expect(Nanoci::Plugin.plugins).to include(Nanoci::Plugins::Git::PluginGit)
  end

  it 'registers RepoGit' do
    plugin = Nanoci::Plugins::Git::PluginGit.new
    expect(Nanoci::Repo.types).to include 'git' => Nanoci::Plugins::Git::RepoGit
  end
end
