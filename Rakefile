require 'bundler'
Bundler::GemHelper.install_tasks

desc "Open an IRB session preloaded with Acceleration"
task :console do
  sh "irb -rubygems -I lib -r acceleration.rb"
end
task :doc do
  sh "rdoc lib"
end
