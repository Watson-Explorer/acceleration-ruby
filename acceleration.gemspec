# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path '../lib', __FILE__
require 'acceleration/version'

Gem::Specification.new do |s|
  s.name = 'acceleration'
  s.version = Acceleration::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Colin Dean']
  s.email = ['colindean@us.ibm.com']
  s.homepage = 'https://github.com/watson-explorer'
  product_name = 'IBM Watson Explorer Foundational Components Engine'
  s.summary = "A succinct interface to to the #{product_name} REST API"
  s.description = <<-END.gsub(/^ {6}/, '')
      Acceleration provides a succinct, ActiveResource-style interface to a the
      #{product_name} search platform instance's REST API. Acceleration is
      derived from Velocity, the original name for Engine.
      END

  ['nokogiri', 'rest-client'].each { |d| s.add_runtime_dependency d }
  %w(semver pry bundler rake).each do |version_unspecified|
    s.add_development_dependency version_unspecified
  end

  s.add_development_dependency 'geminabox', '~> 0.10'
  s.add_development_dependency 'guard', '~> 2.14.0'
  s.add_development_dependency 'guard-bundler', '~> 2.1.0'
  s.add_development_dependency 'guard-rubocop', '~> 1.2.0'
  s.add_development_dependency 'ruby_gntp', '~> 0.3.0'

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`
                  .split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']
end
