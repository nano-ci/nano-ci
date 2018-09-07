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
      sh 'docker build -t nano-ci .'
    end
  end
end
