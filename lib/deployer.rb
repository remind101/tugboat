require 'pathname'
require 'active_support/core_ext'

autoload :Job, 'deployer/models/job'

module Deployer
  autoload :API, 'deployer/api'

  def self.iron_worker
    @iron_worker ||= IronWorkerNG::Client.new
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.setup
    config = YAML.load Pathname('../../config/database.yml').expand_path(__FILE__).read
    ActiveRecord::Base.configurations = config
    ActiveRecord::Base.establish_connection(ENV['RACK_ENV'])
  end
end
