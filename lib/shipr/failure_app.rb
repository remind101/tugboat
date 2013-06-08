module Shipr
  class FailureApp
    def self.call(env)
      new.call(env)
    end

    def call(env)
      [
        401,
        {
          'Content-Type' => 'application/json',
          'WWW-Authenticate' => %(Basic realm="API Authentication")
        },
        [ { error: '401 Unauthorized' }.to_json ]
      ]
    end
  end
end
