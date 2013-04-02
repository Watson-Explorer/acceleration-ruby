Acceleration
============

A succinct interface to the Vivísimo Velocity API

by Colin Dean <cdean@vivisimo.com>

Introduction
------------

Acceleration provides a succinct, ActiveResource-style interface to a Vivísimo
Velocity search platform instance's REST API. Acceleration is derived from
Velocity.

Installation
------------

There are a two places to get Acceleration.

### Gems.vivisimo.com

Install manually:

    gem sources -a https://gems.vivisimo.com/
    gem install acceleration

or add this to your Gemfile:

    source "https://gems.vivisimo.com"
    gem "acceleration"

### From source

Add this to your Gemfile:

    gem 'acceleration', :git => "git@gitlab.vivisimo.com:acceleration.git"

Contributing
------------
Source: https://gitlab.vivisimo.com/acceleration

Issues: https://gitlab.vivisimo.com/acceleration/issues

Pull Requests: https://gitlab.vivisimo.com/acceleration/merge_requests

Please test all changes against Ruby 1.9.3+ and JRuby 1.7+. Proper testing
infrastructure is more than welcome!

### Getting started

This assumes that you already have [RVM](http://rvm.io) installed and
a requisite Ruby installed.

Check out the source:

    git clone git@gitlab.vivisimo.com:acceleration.git
    cd acceration

Accept the RVM notice. If you don't already have the required version of Ruby
installed, install it with `rvm install $rvm_recommended_ruby`.

Install dependencies:

    gem install bundler
    bundle install

Generate documentation:

    rake doc

Now you're clear for hacking. Open the docs with `open doc/index.html` to learn
how to use it. The top-level class is actually **Velocity**.

### Releasing

Acceleration uses semantic versioning. Once all work for a version is
committed, increment the version number in lib/acceleration/version.rb and
execute `semver inc patch`, or whatever else is appropriate for the release.
Then, commit the changes to `lib/acceleration/version.rb` and `.semver` with
`git commit -a -m "version $(semver tag)"` and then tag it with `git tag
$(semver tag)`.

