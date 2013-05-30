require 'pathname'
require 'active_support/core_ext'
require 'rack/force_json'
require 'rack/contrib/post_body_content_type_parser'

require 'shipr/warden'

autoload :Job, 'shipr/models/job'

module Shipr
  autoload :API,    'shipr/api'
  autoload :Update, 'shipr/update'

  def self.redis
    @redis ||= begin
      if url = ENV['REDIS_URL']
        uri = URI.parse(url)
        Redis.new(host: uri.host, port: uri.port, password: uri.password)
      else
        Redis.new
      end
    end
  end

  def self.workers
    @workers ||= IronWorkerNG::Client.new
  end

  def self.messages
    @messages ||= IronMQ::Client.new
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.setup
    subscribers = [
      { url: "https://#{ENV['DOMAIN']}/_update" }
    ]
    messages.queue('update').update \
      subscribers: subscribers,
      push_type: :multicast
  end

  def self.app
    @app ||= Rack::Builder.app do
      use Rack::SSL if ENV['RACK_ENV'] == 'production'

      use Rack::Session::Cookie, key: '_shipr_session'

      map '/_update' do
        use Rack::ForceJSON
        use Rack::PostBodyContentTypeParser
        run Update
      end

      map '/' do
        use Warden::Manager do |manager|
          manager.default_strategies :basic
          manager.failure_app = lambda do |env|
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

        run API
      end
    end
  end
end
