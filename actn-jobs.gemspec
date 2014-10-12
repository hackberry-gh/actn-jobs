# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'actn/jobs/version'

Gem::Specification.new do |spec|
  spec.name          = "actn-jobs"
  spec.version       = Actn::Jobs::VERSION
  spec.authors       = ["Onur Uyar"]
  spec.email         = ["me@onuruyar.com"]
  spec.summary       = %q{Actn.io Jobs}
  spec.homepage      = "https://github.com/hackberry-gh/actn-jobs"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  
   # spec.add_dependency 'actn-db', '~> 0.0.4'
end
