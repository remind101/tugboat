module Shipr
  class API < Grape::API
    logger Shipr.logger
    version 'v1', using: :header, vendor: 'shipr'
    format :json

    helpers do
      delegate :iron_worker, to: Shipr

      def deploy(*args)
        Job.create(*args)
      end
    end

    desc 'Deploy.'
    params do
      requires :repo,
        type: String
      requires :environment,
        type: String
    end
    post :deploy do
      present deploy(declared params)
    end
  end
end
