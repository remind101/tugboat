ENV['RACK_ENV'] ||= 'development'

require 'bundler/setup'
Bundler.require :default, ENV['RACK_ENV']
Dotenv.load if defined?(Dotenv)

class API < Grape::API
  logger Logger.new(STDOUT)
  version 'v1', using: :header, vendor: 'heroku'
  format :json

  helpers do
    def iron_worker
      @iron_worker ||= IronWorkerNG::Client.new
    end
  end

  desc 'Deploy a git repo to a Heroku app.'
  params do
    requires :repo, type: String
    requires :app, type: String
    optional :notify, type: String
  end
  post do
    iron_worker.tasks.create('deploy', params)
    { }
  end
end

run API
