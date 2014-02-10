require 'pathname'
require 'open-uri'
require 'active_support/core_ext'
require 'rack/force_json'

require 'shipr/warden'
require 'shipr/consumers/output_consumer'
require 'shipr/consumers/completion_consumer'
require 'shipr/consumers/pusher_consumer'

module Shipr
  autoload :API, 'shipr/api'
  autoload :Web, 'shipr/web'
  autoload :Job, 'shipr/job'

  module Hooks
    autoload :Pusher, 'shipr/hooks/pusher'
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

    # Public: An easy way to configure and fetch a default deploy script to
    # use. Works great for hosting a deploy script in a gist.
    #
    # Examples
    #
    #   Shipr.default_script
    #   # => "git push git@heroku.com:app.git HEAD:master"
    #
    # Returns the String content of the deploy script.
    def default_script
      @default_script ||= begin
        uri = URI.parse(ENV['DEPLOY_SCRIPT_URL']) rescue nil
        return nil unless uri
        open(uri).read
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
        use Rack::Deflater

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
