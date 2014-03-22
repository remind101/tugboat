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

      def declared(params)
        super(params).select { |_, val| !val.nil? }
      end

      def deploy
        Shipr::GitHub::Deployment.create(params.name, declared(params).except(:name))
      end
    end

    namespace :deploys do
      before do
        authenticate!
      end

      desc 'Deploy.'
      params do
        requires :name, type: String
        requires :ref, type: String
        optional :force, type: Boolean
        optional :auto_merge, type: Boolean
        optional :payload, type: Hash
      end
      post do
        deploy
        present {}
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

        desc 'Restart a job.'
        post :restart do
          job = jobs.find(params.id).restart!
          status 200
          present job
        end
      end
    end
  end
end
