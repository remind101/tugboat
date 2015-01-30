require 'pathname'
require 'open-uri'
require 'active_support/core_ext'
require 'rack/force_json'

require 'shipr/warden'
require 'shipr/consumers/worker_output_consumer'
require 'shipr/consumers/worker_completion_consumer'
require 'shipr/consumers/pusher_consumer'

module Shipr
  autoload :Configuration,   'shipr/configuration'
  autoload :API,             'shipr/api'
  autoload :Web,             'shipr/web'
  autoload :PusherAuth,      'shipr/pusher_auth'
  autoload :Unauthenticated, 'shipr/unauthenticated'

  autoload :Repo, 'shipr/repo'
  autoload :Job,  'shipr/job'

  module Provider
    autoload :Base,       'shipr/provider/base'
    autoload :IronWorker, 'shipr/provider/iron_worker'
    autoload :Empire,     'shipr/provider/empire'
    autoload :Null,       'shipr/provider/null'
  end

  module Deployments
    autoload :AbstractService,     'shipr/deployments/abstract_service'
    autoload :BaseService,         'shipr/deployments/base_service'
    autoload :PushedService,       'shipr/deployments/pushed_service'
    autoload :DeployService,       'shipr/deployments/deploy_service'
    autoload :GitHubStatusService, 'shipr/deployments/github_status_service'
  end

  module Entities
    autoload :Repo, 'shipr/entities/repo'
    autoload :Job,  'shipr/entities/job'
  end

  module Hooks
    autoload :GitHub, 'shipr/hooks/github'
  end

  module Notifier
    autoload :Payload, 'shipr/notifier/payload'
    autoload :Base,    'shipr/notifier/base'
    autoload :Slack,   'shipr/notifier/slack'
    autoload :Null,    'shipr/notifier/null'
  end

  module GitHub
    autoload :Client,               'shipr/github/client'
    autoload :Deployment,           'shipr/github/deployment'
    autoload :Hook,                 'shipr/github/hook'
    autoload :DeploymentHook,       'shipr/github/deployment_hook'
    autoload :DeploymentStatusHook, 'shipr/github/deployment_status_hook'
  end

  class << self
    
    def configuration
      @configuration ||= Configuration.new
    end

    def deployments_service
      @deployments_service ||= Deployments::PushedService.new(
        Deployments::GitHubStatusService.new(
          Deployments::DeployService.new(
            Deployments::BaseService.new,
            configuration.provider
          ),
          github
        ),
        self
      )
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

    # Public: A github client.
    def github
      @github ||= Shipr::GitHub::Client.new(token: configuration.github_deploy_token)
    end

    # Public: Publish a rabbitmq message.
    #
    # Returns nothing.
    def publish(*args)
      Hutch.publish(*args)
    end

    # Public: Trigger a pusher event.
    #
    # Returns nothing.
    def trigger(channel, event, data)
      publish('pusher.push', channel: channel, event: event, data: data)
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
      warden = proc do |manager|
        manager.default_strategies :basic
        manager.failure_app = Unauthenticated
      end

      @app ||= Rack::Builder.app do
        use Rack::Deflater
        use Rack::SSL if ENV['RACK_ENV'] == 'production'
        use Rack::Session::Cookie, key: '_shipr_session', secret: Shipr.configuration.cookie_secret

        map '/pusher/auth' do
          use Warden::Manager
          run PusherAuth
        end

        map '/_github' do
          use Warden::Manager, &warden
          run Hooks::GitHub
        end

        map '/api' do
          use Warden::Manager, &warden
          run API
        end

        map '/' do
          run Web
        end
      end
    end
  end
end
