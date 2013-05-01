require 'sidekiq'
require 'open3'

class Deploy
  include Sidekiq::Worker

  def perform(params)
    Open3.popen3(File.expand_path('../bin/deploy', __FILE__)) do |stdin, stdout, stderr, wait_thr|
      puts stdout.read
      wait_thr.value
    end
  end
end
