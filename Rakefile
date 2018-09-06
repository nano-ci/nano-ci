require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

NANO_CI_GEM='nanoci-0.1.0.gem'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

file NANO_CI_GEM => :gem

task :gem do
  sh 'gem build nanoci.gemspec'
end

namespace :docker do
  file "docker/nano-ci/#{NANO_CI_GEM}" => NANO_CI_GEM do |task|
    cp task.prerequisites.first, task.name
  end


  task :'nano-ci' => "docker/nano-ci/#{NANO_CI_GEM}" do
    Dir.chdir 'docker/nano-ci' do
      sh 'docker build .'
    end
  end
end
