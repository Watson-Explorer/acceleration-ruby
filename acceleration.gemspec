# -*- encoding: utf-8 -*-
$:.push File.expand_path "../lib", __FILE__
require "acceleration/version"

Gem::Specification.new do |s|
  s.name = "acceleration"
  s.version = Acceleration::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Colin Dean"]
  s.email = ["colindean@us.ibm.com"]
  s.homepage = "https://github.com/watson-explorer"
  s.summary = %q{A succinct interface to the A succinct interface to the IBM Watson Explorer Foundational Components Engine REST API}
  s.description = %q{Acceleration provides a succinct, ActiveResource-style interface to a A succinct interface to the IBM Watson Explorer Foundational Components Engine search platform instance's REST API. Acceleration is derived from Velocity, the original name for Engine.}

  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "rest-client"
  s.add_development_dependency "semver"
  s.add_development_dependency "pry"
  s.add_development_dependency "bundler"
  s.add_development_dependency "geminabox", "~> 0.10"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.require_paths = ["lib"]
end
