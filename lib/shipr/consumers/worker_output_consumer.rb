module Shipr
  module Consumers
    class WorkerOutputConsumer
      include Hutch::Consumer
      consume 'worker.output'

      def process(message)
        job = Job.find(message[:id])
        deployments_service.append_output job, message[:output]
      end

      private

      def deployments_service
        Shipr.deployments_service
      end
    end
  end
end
