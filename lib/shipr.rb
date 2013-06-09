require 'pathname'
require 'active_support/core_ext'
require 'rack/force_json'

require 'shipr/warden'

autoload :Job, 'shipr/models/job'

module Shipr
  autoload :API,          'shipr/api'
  autoload :Web,          'shipr/web'
  autoload :QueueHandler, 'shipr/queue_handler'
  autoload :FailureApp,   'shipr/failure_app'

  module Hooks
    autoload :Pusher, 'shipr/hooks/pusher'
  end

  module Queues
    autoload :Base,   'shipr/queues/base'
    autoload :Update, 'shipr/queues/update'
  end

  class << self

    def workers
      @workers ||= IronWorkerNG::Client.new
    end

    def messages
      @messages ||= IronMQ::Client.new
    end

    def pusher
      @pusher ||= begin
        uri = URI.parse(ENV['PUSHER_URL'])
        Pusher.key = uri.user
        Pusher.secret = uri.password
        Pusher.app_id = uri.path.gsub '/apps/', ''
        Pusher
      end
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def connect!
      if ENV['DATABASE_URL']
        ActiveRecord::Base.establish_connection
      else
        config = YAML.load Pathname('../../config/database.yml').expand_path(__FILE__).read
        ActiveRecord::Base.configurations = config
        ActiveRecord::Base.establish_connection(ENV['RACK_ENV'])
      end
    end

    def setup
      connect!
    end

    def app
      @app ||= Rack::Builder.app do
        use Rack::SSL if ENV['RACK_ENV'] == 'production'

        use Rack::Session::Cookie, key: '_shipr_session'

        map '/pusher/auth' do
          use Warden::Manager
          run Hooks::Pusher
        end

        map '/api' do
          use Warden::Manager do |manager|
            manager.default_strategies :basic
            manager.failure_app = FailureApp
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
