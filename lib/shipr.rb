require 'pathname'
require 'active_support/core_ext'

autoload :Job, 'shipr/models/job'

module Shipr
  autoload :API, 'shipr/api'

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
end
