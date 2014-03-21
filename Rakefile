#!/usr/bin/env rake

require File.expand_path('../config/environment', __FILE__)
require 'sinatra/asset_pipeline/task'
Sinatra::AssetPipeline::Task.define! Shipr::Web

desc 'Start an irb session'
task :console do
  require 'irb'
  ARGV.clear
  IRB.start
end

begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format pretty"
  end

  require 'rspec/core/rake_task'
  desc "Run specs"
  RSpec::Core::RakeTask.new do |t|
    t.pattern = 'spec/**/*_spec.rb'
  end

  task default: [:spec, :features]
rescue LoadError
  # The gem shouldn't be installed in a production environment
end

namespace :jobs do
  task :test do
    p Shipr::JobCreator.create('remind101/shipr', sha: '1234')
  end
end
