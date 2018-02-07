# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nanoci/version'

Gem::Specification.new do |spec|
  spec.name          = 'nanoci'
  spec.version       = Nanoci::VERSION
  spec.authors       = ['Andrew Maraev']
  spec.email         = ['the_vk@thevk.net']

  spec.summary       = 'nano-ci'
  spec.description   = 'nano-ci'
  spec.homepage      = 'http://nanoci.net'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.add_runtime_dependency 'eventmachine', '1.2.5'
  spec.add_runtime_dependency 'logging', '~> 2.2'
  spec.add_runtime_dependency 'mongo', '~> 2.5'
  spec.add_runtime_dependency 'trollop', '~> 2.1'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'debase', '0.2.2.beta14'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-mocks', '~> 3.7'
  spec.add_development_dependency 'ruby-debug-ide'
  spec.add_development_dependency 'simplecov', '~> 0.15'
end
