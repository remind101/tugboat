module Deployer
  class API < Grape::API
    logger Deployer.logger
    version 'v1', using: :header, vendor: 'deployer'
    format :json

    helpers do
      delegate :iron_worker, to: Deployer

      def deploy(*args)
        iron_worker.tasks.create('Deploy', *args)
      end
    end

    desc 'Deploy.'
    params do
      requires :repo,
        type: String
      requires :environment,
        type: String
    end
    post do
      authenticate!
      deploy(params)
    end
  end
end
