# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cupper/version'

Gem::Specification.new do |spec|
  spec.name          = "cupper"
  spec.version       = Cupper::VERSION
  spec.authors       = ["Paulo Tada", "Lucas Severo"]
  spec.email         = ["paulohtfs@gmail.com", "lucassalves65@gmail.com"]

  spec.summary       = %q{Taste your system and create a recipe}
  spec.description   = %q{Taste your system and create a recipe}
  spec.homepage      = "https://github.com/cupper-reverse-recipe/cupper"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ""
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = %w{cupper}
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
