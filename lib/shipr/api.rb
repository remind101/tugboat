module Shipr
  class API < Grape::API
    autoload :FailureApp, 'shipr/api/failure_app'

    logger Shipr.logger

    version 'v1', using: :header, vendor: 'shipr'
    format :json

    helpers do
      delegate :authenticate!, to: :warden

      def warden; env['warden'] end

      def deploy(*args)
        Job.create(*args)
      end

      def declared(params)
        super(params).select { |_, val| !val.nil? }
      end
    end

    use Warden::Manager do |manager|
      manager.default_strategies :basic
      manager.failure_app = FailureApp
    end

    namespace :deploys do
      before do
        authenticate!
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

      params do
        requires :id, type: Integer
      end
      get ':id' do
        present Job.find(params.id)
      end
    end
  end
end
