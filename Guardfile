filter(/\.txt$/, /.*\.zip/)

notification :gntp

guard :bundler do
  watch 'Gemfile'
  watch(/\.gemspec$/)
end

group :red_green_refactor, halt_on_fail: true do
  # guard :rspec,
  #      cmd: 'bundle exec rspec',
  #     failed_mode: :keep do
  # watch 'spec/spec_helper.rb'
  # watch(/^spec\/.+_spec\.rb/)
  # watch(/^lib\/(.+)\.rb/)
  # end

  guard :rubocop do
    watch(/.+\.rb$/)
    watch(%r{/(?:.+\/)?\.rubocop\.yml$/}) { |m| File.dirname(m[0]) }
  end
end

scope group: :red_green_refactor
