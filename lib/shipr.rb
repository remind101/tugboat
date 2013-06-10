require 'pathname'
require 'active_support/core_ext'
require 'rack/force_json'

require 'shipr/warden'

autoload :Job, 'shipr/models/job'

module Shipr
  autoload :API,          'shipr/api'
  autoload :Web,          'shipr/web'

  module Hooks
    autoload :Pusher, 'shipr/hooks/pusher'
  end

  module Queues
    autoload :Base,   'shipr/queues/base'
    autoload :Update, 'shipr/queues/update'
  end

  class << self

    # Public: Global Iron Worker client for queueing up new workers. Iron
    # Worker is used to queue new workers that do the heavy lifting when
    # deploying a repo.
    #
    # Examples
    #
    #   Shipr.workers.tasks.create('Deploy', {})
    #
    # Returns an IronWorkerNG::Client instance.
    def workers
      @workers ||= IronWorkerNG::Client.new
    end

    # Public: Global Iron MQ client for queueing and processing messages. Iron
    # MQ is used by the deploy worker when new output is received from the
    # deploy process.
    #
    # Examples
    #
    #   Shipr.messages.queue('update').poll { |msg| puts } msg
    #
    # Returns an IronMQ::Client instance.
    def messages
      @messages ||= IronMQ::Client.new
    end

    # Public: Global Pusher client for pushing events to the frontend client.
    #
    # Examples
    #
    #   Shipr.pusher.trigger('channel', 'event', { data: 'hello!' })
    #
    # Returns Pusher.
    def pusher
      @pusher ||= begin
        uri = URI.parse(ENV['PUSHER_URL'])
        Pusher.key = uri.user
        Pusher.secret = uri.password
        Pusher.app_id = uri.path.gsub '/apps/', ''
        Pusher
      end
    end

    # Public: Logger instance for everything to use.
    #
    # Examples
    #
    #   Shipr.logger.info 'Hello!'
    #
    # Returns a Logger instance.
    def logger
      @logger ||= Logger.new(STDOUT)
    end

    # Internal: Establishes the ActiveRecord connection.
    #
    # Examples
    #
    #   Shipr.connect!
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

    # Public: The app itself. The app is split up into many smaller components.
    #
    # Examples
    #
    #   # config.ru
    #
    #   run Shipr.app
    #
    # Returns a Rack compatible app.
    def app
      @app ||= Rack::Builder.app do
        use Rack::SSL if ENV['RACK_ENV'] == 'production'

        use Rack::Session::Cookie, key: '_shipr_session'

        map '/pusher/auth' do
          run Hooks::Pusher
        end

        map '/api' do
          run API
        end

        map '/' do
          run Web
        end
      end
    end

  end
end
