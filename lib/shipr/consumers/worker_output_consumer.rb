module Shipr
  module Consumers
    class WorkerOutputConsumer
      include Hutch::Consumer
      consume 'worker.output'

      def process(message)
        job = Job.find(message[:id])
        job.append_output!(message[:output])
      end
    end
  end
end
