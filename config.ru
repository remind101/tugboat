require 'bundler/setup'
Bundler.require :default

require './deploy'

class API < Grape::API
  logger Logger.new(STDOUT)
  version 'v1', using: :header, vendor: 'heroku'
  format :json

  desc 'Deploy a git repo to a Heroku app.'
  params do
    requires :repo, type: String
    requires :app, type: String
    optional :notify, type: String
  end
  post do
    Deploy.perform_async(params)
    { }
  end
end

run API
