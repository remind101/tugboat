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

      def required_contexts
        params.force ? [] : nil
      end

      def deploy_params
        p = declared(params).except(:name)
        p.merge!(required_contexts: required_contexts)
        p.select { |_, val| !val.nil? }
      end

      def deploy
        Shipr::GitHub::Deployment.create(params.name, deploy_params)
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
        optional :force, type: Boolean, default: false
        optional :auto_merge, type: Boolean, default: false
        optional :payload, type: Hash
      end
      post do
        begin
          deploy
          present({})
        rescue Faraday::Error::ClientError => e
          status e.response[:status]
          e.response[:body]
        end
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
