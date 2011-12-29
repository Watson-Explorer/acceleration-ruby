# -*- encoding: utf-8 -*-
$:.push File.expand_path "../lib", __FILE__
require "acceleration/version"

Gem::Specification.new do |s|
  s.name = "acceleration"
  s.version = Acceleration::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Colin Dean"]
  s.email = ["cdean@vivisimo.com"]
  s.homepage = "http://www.vivisimo.com"
  s.summary = %q{A succinct interface to the Vivísimo Velocity API}
  s.description = %q{Acceleration provides a succinct, ActiveResource-style interface to a Vivísimo Velocity search platform instance's REST API. Acceleration is derived from Velocity.}

  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "rest-client"
  s.add_development_dependency "semver"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.require_paths = ["lib"]
end
