module Shipr
  class API < Grape::API
    logger Shipr.logger

    version 'v1', using: :header, vendor: 'shipr'
    format :json

    helpers do
      delegate :authenticate!, to: :warden

      def warden; env['warden'] end

      def jobs
        Job.order('created_at asc')
      end

      def deploy(*args)
        Job.create(*args)
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
        present jobs
      end

      desc 'Deploy.'
      params do
        requires :repo, type: String
        optional :config, type: Hash
        optional :branch, type: String
      end
      post do
        present deploy(declared params)
      end

      desc 'Get the JSON representation of a deploy.'
      params do
        requires :id, type: Integer
      end
      get ':id' do
        present jobs.find(params.id)
      end
    end
  end
end
