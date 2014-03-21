module Shipr
  # Internal: Used to authenticate pusher channels.
  class PusherAuth < Grape::API
    logger Shipr.logger

    format :json

    helpers do
      delegate :pusher, to: :'Shipr'
      delegate :authenticated?, to: :warden

      def warden; env['warden'] end
    end

    params do
      requires :socket_id, type: String
      requires :channel_name, type: String
    end
    post do
      if authenticated?
        status 200
        pusher[params.channel_name].authenticate(params.socket_id)
      else
        error!('Forbidden', 403)
      end
    end
  end
end
