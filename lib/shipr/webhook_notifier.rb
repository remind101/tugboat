module Shipr
  class WebhookNotifier
    attr_reader :url, :job

    def initialize(url, job)
      @url = url
      @job = job
    end

    def self.notify(*args)
      new(*args).notify
    end

    def notify
      Faraday.post(url, job.entity.to_json) do |req|
        req.headers['Content-Type'] = 'application/json'
      end
    end
  end
end
