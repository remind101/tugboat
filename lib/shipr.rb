require 'pathname'
require 'active_support/core_ext'

autoload :Job, 'shipr/models/job'

module Shipr
  autoload :API, 'shipr/api'

  def self.redis=(redis)
    @redis = redis
  end

  def self.redis
    @redis ||= Redis.new
  end

  def self.iron_worker
    @iron_worker ||= IronWorkerNG::Client.new
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end
