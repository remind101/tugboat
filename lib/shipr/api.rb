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

    namespace :deploy do
      desc 'Deploy.'
      params do
        requires :repo,
          type: String
        requires :environment,
          type: String
      end
      post do
        present deploy(declared params)
      end

      params do
        requires :uuid,
          type: String
      end
      get ':uuid' do
        present Job.find(params.uuid)
      end
    end
  end
end
