module Shipr
  module Consumers
    class WorkerCompletionConsumer
      include Hutch::Consumer
      consume 'worker.complete'

      def process(message)
        job = Job.find(message[:id])
        deployments_service.completed job, message[:exit_status]
      end

      private

      delegate :deployments_service, to: :Shipr
    end
  end
end
