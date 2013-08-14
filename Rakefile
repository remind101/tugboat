#!/usr/bin/env rake

require File.expand_path('../config/environment', __FILE__)
require 'shipr/tasks'

begin
  require 'micro_migrations'
rescue LoadError
  # Not used in production
end

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

namespace :jobs do
  task :test do
    Job.create(repo: 'git@github.com:remind101/shipr.git')
  end
end
