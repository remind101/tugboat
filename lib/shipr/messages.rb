module Shipr
  class Messages < Grape::API
    logger Shipr.logger
    version 'v1', using: :header, vendor: 'shipr'
    format :json

    post '/progress' do
      log params
      200
    end

    post '/status' do
      log params
      200
    end
  end
end
