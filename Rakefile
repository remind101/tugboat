#!/usr/bin/env rake

require 'bundler/setup'
require 'deployer'

desc 'Start an irb session'
task :console do
  require 'irb'
  ARGV.clear
  IRB.start
end

task :default => [:spec]

begin
  require 'rspec/core/rake_task'
  desc "Run specs"
  RSpec::Core::RakeTask.new do |t|
    t.pattern = 'spec/**/*_spec.rb'
  end
rescue LoadError
  # The gem shouldn't be installed in a production environment
end
