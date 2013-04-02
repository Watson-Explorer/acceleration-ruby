require 'bundler'
Bundler::GemHelper.install_tasks

desc "Open an IRB session preloaded with Acceleration"
task :console do
  sh "pry -rubygems -I lib -r acceleration.rb"
end
desc "Compile documentation using RDoc"
task :doc do
  sh "rdoc --main Velocity lib"
end

module Bundler
  class GemHelper
    protected
      def rubygem_push(path)
        puts "** running gem inabox '#{path}'"
        sh "gem inabox '#{path}'"
      end
  end
end
