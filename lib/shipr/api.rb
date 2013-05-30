module Shipr
  class API < Grape::API
    logger Shipr.logger
    version 'v1', using: :header, vendor: 'shipr'
    format :json

    helpers do
      delegate \
        :user,
        :authenticate!,
        :authenticate?,

        to: :warden

      def deploy(*args)
        Job.create(*args)
      end

      def session; env['rack.session'] end
      def warden; env['warden'] end

      def declared(params)
        super(params).select { |_, val| !val.nil? }
      end
    end

    namespace :deploy do
      before do
        authenticate!
      end

      desc 'Deploy.'
      params do
        requires :repo,
          type: String
        optional :config,
          type: Hash
        optional :treeish,
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
