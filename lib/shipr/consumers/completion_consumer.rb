module Shipr
  module Consumers
    class CompletionConsumer
      include Hutch::Consumer
      consume 'job.complete'

      def process(message)
        job = Job.find(message[:id])
        job.complete!(message[:exit_status])
      end
    end
  end
end
