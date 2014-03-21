module Shipr
  class Unauthenticated < Grape::API
    logger Shipr.logger

    format :json
    default_format :json

    route :any do
      header 'WWW-Authenticate', %(Basic realm="API Authentication")
      status 401
      { error: 'Unauthorized' }
    end
  end
end
