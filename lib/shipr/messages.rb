module Shipr
  class Messages < Grape::API
    logger Shipr.logger
    version 'v1', using: :header, vendor: 'shipr'
    format :json

    post '/progress' do
      puts params
    end

    post '/status' do
      puts params
    end
  end
end
