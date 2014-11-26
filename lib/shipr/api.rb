module Shipr
  class API < Grape::API
    logger Shipr.logger

    version 'v1', using: :header, vendor: 'shipr'
    format :json
    default_format :json

    represent Shipr::Job,  with: Entities::Job
    represent Shipr::Repo, with: Entities::Repo

    helpers do
      delegate :authenticate!, to: :warden

      def warden; env['warden'] end

      def jobs
        Job.desc(:id)
      end
    end

    namespace :deploys do
      before do
        authenticate!
      end

      desc 'Returns all deploys.'
      get do
        present jobs.limit(30)
      end

      params do
        requires :id, type: String
      end
      namespace ':id' do
        desc 'Get the JSON representation of a deploy.'
        get do
          present jobs.find(params.id), include_output: true
        end
      end
    end
  end
end
