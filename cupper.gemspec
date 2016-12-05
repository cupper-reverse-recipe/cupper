# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cupper/version'

Gem::Specification.new do |spec|
  spec.name          = 'cupper'
  spec.version       = Cupper::VERSION
  spec.authors       = ['Paulo Tada', 'Lucas Severo']
  spec.email         = ['paulohtfs@gmail.com', 'lucassalves65@gmail.com']

  spec.summary       = 'Reverse recipe'
  spec.description   = 'Taste your system and create a recipe'
  spec.homepage      = 'https://github.com/cupper-reverse-recipe/cupper'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|featires)/)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_runtime_dependency 'thor', '~> 0.19.1'
  spec.add_runtime_dependency 'ohai', '~> 8.15', '>= 8.15.1'
end
