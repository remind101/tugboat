#!/usr/bin/env rake
require File.expand_path('../config/environment', __FILE__)
Deployer.connect!

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

namespace :db do
  desc 'Drop, create and migrate the databse'
  task :reset do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
  end

  desc "Create the database using DATABASE_URL"
  task :create do
    ActiveRecord::Base.establish_connection(Deployer.database_configuration.merge('database' => 'postgres', 'schema_search_path' => 'public'))
    ActiveRecord::Base.connection.create_database(Deployer.database_configuration['database'])
    ActiveRecord::Base.establish_connection(Deployer.database_configuration)
  end

  desc "Drop the database using DATABASE_URL"
  task :drop do
    ActiveRecord::Base.establish_connection(Deployer.database_configuration.merge('database' => 'postgres', 'schema_search_path' => 'public'))
    ActiveRecord::Base.connection.drop_database(Deployer.database_configuration['database'])
  end

  desc "Run the migration(s)"
  task :migrate do
    path = File.expand_path('../db/migrate', __FILE__)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate(path)
  end
end
