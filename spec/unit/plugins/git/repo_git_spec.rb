require 'spec_helper'

require 'nanoci/plugins/git/repo_git'

RSpec.describe Nanoci::Plugins::Git::RepoGit do
  it 'adds required capabilitiy "tools.git"' do
    repo = Nanoci::Plugins::Git::RepoGit.new
    expect(repo.required_agent_capabilities).to include 'tools.git'
  end
end
