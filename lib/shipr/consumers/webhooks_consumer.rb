module Shipr
  module Consumers
    class WebhooksConsumer
      include Hutch::Consumer
      consume 'job.complete'

      def process(message)
        job = Job.find(message[:id])
        job.notify.each do |url|
          WebhookNotifier.notify(url, job)
        end
      end
    end
  end
end
