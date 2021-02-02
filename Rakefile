# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/clean'
require 'rspec/core/rake_task'

# tools

GRPC = 'grpc_tools_ruby_protoc'

Dir['lib/rake/*.rb'].sort.each { |file| require file }

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

CLEAN.include('docker/nano-ci/nano-ci/*')

RSpec::Core::RakeTask.new(:spec)

task default: :spec

file NANO_CI_GEM => :gem

task :gem do
  sh 'gem build nanoci.gemspec'
end

REMOTE_GRPC_PATH = 'lib/nanoci/remote'
directory REMOTE_GRPC_PATH

PROTOBUF_FILES.each do |src|
  src_file = File.basename(src, '.proto')
  dst = File.join(REMOTE_GRPC_PATH, "#{src_file}_pb.rb")
  file dst => [REMOTE_GRPC_PATH, src] do
    sh "#{GRPC} -I ./protos --ruby_out=#{REMOTE_GRPC_PATH} --grpc_out=#{REMOTE_GRPC_PATH} #{src}"
  end

  task grpc: dst
end

namespace :docker do
  NANO_CI_MASTER_CONTAINER = 'nano-ci'
  NANO_CI_MASTER_DEBUG_CONTAINER = 'nano-ci-debug'
  NANO_CI_AGENT_CONTAINER = 'nano-ci-agent'
  NANO_CI_AGENT_DEBUG_CONTAINER = 'nano-ci-agent-debug'

  NANO_CI_NET = 'nano-ci-net'
  NANO_CI_DEBUG_NET = 'nano-ci-debug-net'

  task :'nano-ci-net' do
    sh "docker network create #{NANO_CI_NET}"
  end

  task :'nano-ci-debug-net' do
    sh "docker network create #{NANO_CI_DEBUG_NET}"
  end

  namespace :mongo do
    task :run do
      sh 'docker run -d -p 27017:27017 --name mongo mongo'
      sh "docker network connect #{NANO_CI_NET} mongo"
      sh "docker network connect #{NANO_CI_DEBUG_NET} mongo"
    end
  end

  task run: [:'nano-ci-master'] do
    Dir.chdir 'docker' do
      sh 'docker-compose up'
    end
  end

  NANO_CI_FILES.each do |src|
    file "docker/nano-ci/nano-ci/#{src}" => src do |task|
      mkdir_p(File.dirname(task.name))
      cp task.prerequisites.first, task.name
    end

    task 'nano-ci': "docker/nano-ci/nano-ci/#{src}"
  end

  task 'nano-ci': [:grpc] do
    Dir.chdir 'docker/nano-ci' do
      sh 'docker build --target nano-ci-base -t nano-ci .'
    end
  end

  namespace :'nano-ci' do
    task run: [:'docker:nano-ci'] do
      sh 'docker run nano-ci'
    end
  end

  file 'docker/nano-ci/master.nanoci' => 'master.nanoci' do |task|
    mkdir_p(File.dirname(task.name))
    cp task.prerequisites.first, task.name
  end

  task 'nano-ci-master': [:'docker:nano-ci', 'docker/nano-ci/master.nanoci'] do
    Dir.chdir 'docker/nano-ci' do
      sh 'docker build --target nano-ci-master -t nano-ci-master .'
    end
  end

  task 'nano-ci-agent': [:'docker:nano-ci'] do
    Dir.chdir 'docker/nano-ci-agent' do
      sh 'docker build --target nano-ci-agent -t nano-ci-agent .'
    end
  end

  namespace :'nano-ci-master' do
    task run: [:'docker:nano-ci-master'] do
      sh "docker run --detach --network #{NANO_CI_NET} --net-alias nanoci --name #{NANO_CI_MASTER_CONTAINER} nano-ci-master"
    end

    task :debug => [:'docker:nano-ci-master'] do
      sh "docker run --detach --network #{NANO_CI_DEBUG_NET} --net-alias nanoci --name #{NANO_CI_MASTER_DEBUG_CONTAINER} --entrypoint \"rdebug-ide\" --expose 23456 -p 23456:23456 nano-ci-master --host 0.0.0.0 --port 23456 -- /nano-ci/bin/nano-ci --project=/nano-ci-agent/master.nanoci"
    end

    task :'debug-logs' do
      sh "docker logs #{NANO_CI_MASTER_DEBUG_CONTAINER}"
    end

    task :'debug-logs-follow' do
      sh "docker logs --follow #{NANO_CI_MASTER_DEBUG_CONTAINER}"
    end

    task :'debug-clean' => [:'debug-logs'] do
      sh "docker container rm #{NANO_CI_MASTER_DEBUG_CONTAINER}"
    end
  end

  namespace :'nano-ci-agent' do
    task :run => [:'docker:nano-ci-agent'] do
      sh "docker run --detach --network #{NANO_CI_NET} --name #{NANO_CI_AGENT_CONTAINER} nano-ci-agent"
    end

    task :debug => [:'docker:nano-ci-agent'] do
      sh "docker run --detach --network #{NANO_CI_DEBUG_NET} --name #{NANO_CI_AGENT_DEBUG_CONTAINER} --entrypoint \"rdebug-ide\" --expose 23457 -p 23457:23457 nano-ci-agent --host 0.0.0.0 --port 23457 -- /nano-ci/bin/nano-ci-agent"
    end

    task :'debug-logs' do
      sh "docker logs #{NANO_CI_AGENT_DEBUG_CONTAINER}"
    end

    task :'debug-logs-follow' do
      sh "docker logs --follow #{NANO_CI_AGENT_DEBUG_CONTAINER}"
    end

    task :'debug-clean' => [:'debug-logs'] do
      sh "docker container rm #{NANO_CI_AGENT_DEBUG_CONTAINER}"
    end
  end
end
