require 'pathname'
require 'active_support/core_ext'

autoload :Job, 'shipr/models/job'

module Shipr
  autoload :API,      'shipr/api'
  autoload :Messages, 'shipr/messages'

  def self.redis=(redis)
    @redis = redis
  end

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

  def self.messages_endpoint
    "https://#{ENV['DOMAIN']}/_messages"
  end

  def self.setup
    %w[progress status].each do |queue|
      subscribers = [ { url: [messages_endpoint, queue].join('/') } ]
      messages.queue(queue).update \
        subscribers: subscribers,
        push_type: :multicast
    end
  end

  def self.app
    @app ||= Rack::Builder.app do
      map '/_messages' do
        run Messages
      end

      map '/' do
        run API
      end
    end
  end
end
