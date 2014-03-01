module Shipr
  class API < Grape::API
    logger Shipr.logger

    version 'v1', using: :header, vendor: 'shipr'
    format :json
    default_format :json

    helpers do
      delegate :authenticate!, to: :warden

      def warden; env['warden'] end

      def jobs
        Job.desc(:id)
      end

      def deploy(*args)
        JobCreator.create(*args)
      end

      def declared(params)
        super(params).select { |_, val| !val.nil? }
      end
    end

    use Warden::Manager do |manager|
      manager.default_strategies :basic
      manager.failure_app = self
    end

    get :unauthenticated do
      header 'WWW-Authenticate', %(Basic realm="API Authentication")
      status 401
      { error: 'Unauthorized' }
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
