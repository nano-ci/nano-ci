# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nanoci/version'

Gem::Specification.new do |spec|
  spec.name          = 'nanoci'
  spec.version       = Nanoci::VERSION
  spec.authors       = ['Andrew Maraev']
  spec.email         = ['the_vk@thevk.net']

  spec.summary       = 'nano-ci'
  spec.description   = 'nano-ci is a minimalistic CI/CD service'
  spec.homepage      = 'http://nanoci.net'
  spec.license       = 'MIT'
  spec.required_ruby_version = '~> 3.0'

  spec.files         = Dir.glob('{bin,lib}/**/*') + %w[LICENSE.txt README.md]
  spec.bindir        = 'bin'
  spec.executables   = ['nano-ci']
  spec.require_paths = ['lib']

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.add_runtime_dependency 'bundler', '~> 2.0'
  spec.add_runtime_dependency 'concurrent-ruby', '~> 1.0'
  spec.add_runtime_dependency 'concurrent-ruby-edge', '~> 0.4'
  spec.add_runtime_dependency 'grpc', '~> 1.50.0'
  spec.add_runtime_dependency 'intake', '~> 0.2'
  spec.add_runtime_dependency 'mail', '~> 2.7'
  spec.add_runtime_dependency 'mongo', '~> 2.18'
  spec.add_runtime_dependency 'precursor', '~> 0.8'
  spec.add_runtime_dependency 'ruby-enum', '~> 0.7'

  spec.add_development_dependency 'code-scanning-rubocop', '~> 0.5'
  spec.add_development_dependency 'grpc-tools', '1.43.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-mocks', '~> 3.7'
  spec.add_development_dependency 'rubocop', '~> 1.20'
  spec.add_development_dependency 'simplecov', '~> 0.15'
end
