Acceleration
============

A succinct interface to the IBM Watson Explorer Foundational Components Engine REST API

by Colin Dean <colindean@us.ibm.com>

Introduction
------------

Acceleration provides a succinct, ActiveResource-style interface to a IBM Watson Explorer Foundational Components (WEX-FC) Engine search platform instance's REST API.

The name comes from WEX-FC's pre-acquisition name, Vivísimo Velocity. Acceleration is derived from Velocity. Get it?

License
-------

This library is property of IBM Corporation and licensed under the MIT license.
See LICENSE.md for license terms.

(C) Copyright IBM Corporation. 2012-2016. AWSOM WAT056420161228.

Installation
------------

    gem install acceleration

Contributing
------------

Please test all changes against Ruby 1.9.3+ and JRuby 1.7+. Proper testing
infrastructure is more than welcome!

### Getting started

Check out the source:

    git clone git@github.com:Watson-Explorer/acceleration-ruby.git
    cd acceleration

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
