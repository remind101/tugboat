require 'sidekiq'
require 'open3'

# If your client is single-threaded, we just need a single connection in our Redis connection pool
Sidekiq.configure_client do |config|
  config.redis = { :size => 1, :url => ENV['REDIS_URL'] }
end

# Sidekiq server is multi-threaded so our Redis connection pool size defaults to concurrency (-c)
Sidekiq.configure_server do |config|
  config.redis = { :url => ENV['REDIS_URL'] }
end

class Deploy
  include Sidekiq::Worker

  def perform(params)
    Open3.popen3(File.expand_path('../bin/deploy', __FILE__)) do |stdin, stdout, stderr, wait_thr|
      puts stdout.read
      wait_thr.value
    end
  end
end
