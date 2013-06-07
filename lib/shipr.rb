require 'pathname'
require 'active_support/core_ext'
require 'rack/force_json'
require 'rack/contrib/post_body_content_type_parser'

require 'shipr/warden'

autoload :Job, 'shipr/models/job'

module Shipr
  autoload :API,   'shipr/api'
  autoload :Web,   'shipr/web'
  autoload :Hooks, 'shipr/hooks'

  class << self

    def redis
      Redis.current
    end

    def workers
      @workers ||= IronWorkerNG::Client.new
    end

    def messages
      @messages ||= begin
        messages = IronMQ::Client.new
        subscribers = [
          { url: "https://#{ENV['DOMAIN']}/_hooks" }
        ]
        messages.queue('update').update \
          subscribers: subscribers,
          push_type: :multicast
        messages
      end
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def setup
      if ENV['RACK_ENV'] == 'production'
        ActiveRecord::Base.establish_connection
      else
        config = YAML.load Pathname('../../config/database.yml').expand_path(__FILE__).read
        ActiveRecord::Base.configurations = config
        ActiveRecord::Base.establish_connection(ENV['RACK_ENV'])
      end
    end

    def app
      @app ||= Rack::Builder.app do
        use Rack::SSL if ENV['RACK_ENV'] == 'production'

        use Rack::Session::Cookie, key: '_shipr_session'

        map '/_hooks' do
          use Rack::ForceJSON
          use Rack::PostBodyContentTypeParser
          run Hooks
        end

        map '/api' do
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

        map '/' do
          run Web
        end
      end
    end

  end
end
