require 'bundler/setup'
Bundler.require :default
require 'active_support/core_ext'

require 'deployer/warden'

autoload :User, 'deployer/models/user'

module Deployer
  autoload :API, 'deployer/api'

  def self.iron_worker
    @iron_worker ||= IronWorkerNG::Client.new
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  ##
  # StringInquirer for RACK_ENV
  #
  # Example
  # 
  #   env.production?
  #   # => true
  def self.env
    ActiveSupport::StringInquirer.new(ENV['RACK_ENV'])
  end

  ##
  # Rack app to run
  def self.app
    @app ||= Rack::Builder.app do
      use Rack::Session::Cookie,
        key: '_heroku_deployer',
        secret: ENV['COOKIE_SECRET'].to_s

      use Warden::Manager do |config|
        config.failure_app = lambda do |env|
          [
            401,
            { 'Content-Type' => 'application/json' },
            [ { error: 'Unauthorized' }.to_json ]
          ]
        end
        config.default_strategies :apikey
      end

      run API
    end
  end

  ##
  # Database configuration.
  def self.database_configuration
    @database_configuration ||= begin
      database = URI(ENV['DATABASE_URL'] || "postgresql://localhost:5432/heroku_deployer_#{Deployer.env}")
      { adapter: 'postgresql',
        pool: 5,
        database: database.path[1..-1],
        username: database.user,
        password: database.password,
        host: database.host,
        port: database.port }.with_indifferent_access
    end
  end

  ##
  # Establish a connection to the database.
  def self.connect!
    ActiveRecord::Base.establish_connection(database_configuration)
  end
end
