# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

Dir['lib/rake/*.rb'].each { |file| require file }

NANO_CI_GEM = 'nanoci-0.1.0.gem'

NANO_CI_FILES = Rake::FileList[
  'bin/*',
  'lib/*.rb',
  'lib/**/*.rb',
  'Gemfile',
  'Gemfile.lock',
  'LICENSE.txt',
  'nanoci.gemspec',
  'README.md'
]

RSpec::Core::RakeTask.new(:spec)

task default: :spec

file NANO_CI_GEM => :gem

task :gem do
  sh 'gem build nanoci.gemspec'
end

namespace :docker do
  NANO_CI_FILES.each do |src|
    file "docker/nano-ci/nano-ci/#{src}" => src do |task|
      mkdir_p(File.dirname(task.name))
      cp task.prerequisites.first, task.name
    end

    task :'nano-ci' => "docker/nano-ci/nano-ci/#{src}"
  end

  task :'nano-ci' do
    Dir.chdir 'docker/nano-ci' do
      sh 'docker build --target nano-ci-base -t nano-ci .'
    end
  end

  task :'nano-ci-debug' do
    Dir.chdir 'docker/nano-ci' do
      sh 'docker build --target nano-ci-debug -t nano-ci-debug .'
    end
  end

  namespace :'nano-ci-debug' do
    task :run => :'docker:nano-ci-debug' do
      sh 'docker run -p 23456:23456 nano-ci-debug'
    end
  end
end
