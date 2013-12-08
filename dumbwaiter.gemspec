# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dumbwaiter/version"

Gem::Specification.new do |spec|
  spec.name          = "dumbwaiter"
  spec.version       = Dumbwaiter::VERSION
  spec.authors       = ["Doc Ritezel"]
  spec.email         = ["doc@ministryofvelocity.com"]
  spec.description   = %q{Hoist your code up to Opsworks}
  spec.summary       = %q{Monitor, deploy and maintain your Opsworks application stacks}
  spec.homepage      = "https://github.com/minifast/dumbwaiter"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "aws-sdk-core"

  spec.add_development_dependency "bundler", "~> 1.3"
end
