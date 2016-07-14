# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hydroponic_bean/version'

Gem::Specification.new do |spec|
  spec.name          = "hydroponic_bean"
  spec.version       = HydroponicBean::VERSION
  spec.authors       = ["Geoffroy Planquart"]
  spec.email         = ["geoffroy@planquart.fr"]

  spec.summary       = %q{Mocking beaneater's connection}
  spec.description   = %q{Mocking a TCP connection to a beanstalkd instance}
  spec.homepage      = "https://github.com/Aethelflaed/hydroponic_bean"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_dependency 'beaneater', '~> 1.0'
end
