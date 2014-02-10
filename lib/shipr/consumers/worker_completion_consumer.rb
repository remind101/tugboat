module Shipr
  module Consumers
    class WorkerCompletionConsumer
      include Hutch::Consumer
      consume 'worker.complete'

      def process(message)
        job = Job.find(message[:id])
        job.complete!(message[:exit_status])
      end
    end
  end
end
