require 'bundler'
Bundler::GemHelper.install_tasks

require 'rubocop/rake_task'

RuboCop::RakeTask.new

desc 'Open an IRB session preloaded with Acceleration'
task :console do
  sh 'pry -rubygems -I lib -racceleration'
end
desc 'Compile documentation using RDoc'
task :doc do
  sh 'rdoc --main Velocity lib'
end

module Bundler
  # Changes behavior of pushing gems to push to an internal gem server
  class GemHelper
    protected

      def rubygem_push(path)
        puts "** running gem inabox '#{path}'"
        sh "gem inabox '#{path}'"
      end
  end
end
