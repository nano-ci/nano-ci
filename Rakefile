require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :gem do
  sh 'gem build nanoci.gemspec'
end

file 'vagrant/prod/nanoci-0.1.0.gem' => :gem do
  cp 'nanoci-0.1.0.gem', 'vagrant/prod/nanoci-0.1.0.gem'
end

task prod_gem: ['vagrant/prod/nanoci-0.1.0.gem']

task prod: ['vagrant/prod/nanoci-0.1.0.gem'] do
  cp 'master.nanoci', 'vagrant/prod/master.nanoci'
  Dir.chdir('vagrant/prod') do
    sh 'vagrant up'
  end
end
