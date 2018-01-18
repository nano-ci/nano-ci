require 'spec_helper'

require 'nanoci/tasks/task_source_control'

RSpec.describe Nanoci::Tasks::TaskSourceControl do
  it 'saves repo_tag from src' do
    task = Nanoci::Tasks::TaskSourceControl.new('repo' => 'abc')
    expect(task.repo_tag).to eq 'abc'
  end

  it 'saves action from src' do
    task = Nanoci::Tasks::TaskSourceControl.new('action' => 'checkout')
    expect(task.action).to eq 'checkout'
  end

  it 'saves workdir from src' do
    task = Nanoci::Tasks::TaskSourceControl.new('workdir' => '/home/project')
    expect(task.workdir).to eq '/home/project'
  end

  it 'returns required_agent_capabilities from project repo' do
    task = Nanoci::Tasks::TaskSourceControl.new('repo' => 'abc')
    repo = double('repo')
    expect(repo).to receive(:required_agent_capabilities).and_return(Set['def'])
    project = double('project')
    expect(project).to receive(:repos).and_return('abc' => repo)
    expect(task.required_agent_capabilities(project)).to include('def')
  end
end
