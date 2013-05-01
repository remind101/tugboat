module Deployer
  class API < Grape::API
    logger Deployer.logger
    version 'v1', using: :header, vendor: 'heroku'
    format :json

    helpers do
      delegate :iron_worker, to: Deployer
    end

    desc 'Deploy a git repo to a Heroku app.'
    params do
      requires :repo, type: String
      requires :app, type: String
      optional :notify, type: String
    end
    post do
      iron_worker.tasks.create('Deploy', params)
    end
  end
end
