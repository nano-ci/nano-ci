# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/clean'
require 'rspec/core/rake_task'

# tools

GRPC = 'grpc_tools_ruby_protoc'

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

PROTOBUF_FILES = Rake::FileList[
  'protos/*.proto'
]

CLEAN.include("docker/nano-ci/nano-ci/*")

RSpec::Core::RakeTask.new(:spec)

task default: :spec

file NANO_CI_GEM => :gem

task :gem do
  sh 'gem build nanoci.gemspec'
end

REMOTE_GRPC_PATH = 'lib/nanoci/remote'
directory REMOTE_GRPC_PATH

PROTOBUF_FILES.each do |src|
  src_file = File.basename(src, '.rb')
  dst = File.join(REMOTE_GRPC_PATH, "#{src_file}_pb.rb")
  file dst => [REMOTE_GRPC_PATH, src] do
    sh "#{GRPC} -I ./protos --ruby_out=#{REMOTE_GRPC_PATH} --grpc_out=#{REMOTE_GRPC_PATH} #{src}"
  end

  task :'grpc' => dst
end

namespace :docker do
  namespace :mongo do
    task :run do
      sh 'docker run -d -p 27017:27017 --name mongo mongo'
    end
  end

  task :'run' => [:'nano-ci-self'] do
    Dir.chdir 'docker' do
      sh 'docker-compose up'
    end
  end

  NANO_CI_FILES.each do |src|
    file "docker/nano-ci/nano-ci/#{src}" => src do |task|
      mkdir_p(File.dirname(task.name))
      cp task.prerequisites.first, task.name
    end

    task :'nano-ci' => "docker/nano-ci/nano-ci/#{src}"
  end

  task :'nano-ci' => [:grpc] do
    Dir.chdir 'docker/nano-ci' do
      sh 'docker build --target nano-ci-base -t nano-ci .'
    end
  end

  namespace :'nano-ci' do
    task :run => :'docker:nano-ci' do
      sh 'docker run nano-ci'
    end
  end

  file 'docker/nano-ci/master.nanoci' => 'master.nanoci' do |task|
    mkdir_p(File.dirname(task.name))
    cp task.prerequisites.first, task.name
  end

  file 'docker/nano-ci/config.yml' => 'config.yml' do |task|
    mkdir_p(File.dirname(task.name))
    cp task.prerequisites.first, task.name
  end

  task :'nano-ci-self' => [:'docker:nano-ci', 'docker/nano-ci/master.nanoci', 'docker/nano-ci/config.yml'] do
    Dir.chdir 'docker/nano-ci' do
      sh 'docker build --target nano-ci-self -t nano-ci-self .'
    end
  end

  namespace :'nano-ci-self' do
    CONTAINER_NAME = "nanocidebug"
    task :run => [:'docker:nano-ci-self'] do
      sh 'docker run --detach --link mongo nano-ci-self'
    end

    task :debug => [:'docker:nano-ci-self'] do
      sh "docker run --detach --link mongo --name #{CONTAINER_NAME} --entrypoint \"rdebug-ide\" --expose 23456 -p 23456:23456 nano-ci-self --host 0.0.0.0 --port 23456 -- /nano-ci/bin/nano-ci --project=/nano-ci-agent/master.nanoci"
    end

    task :'debug-logs' do
      sh "docker logs #{CONTAINER_NAME}"
    end

    task :'debug-clean' => [:'debug-logs'] do
      sh "docker container rm #{CONTAINER_NAME}"
    end
  end
end
