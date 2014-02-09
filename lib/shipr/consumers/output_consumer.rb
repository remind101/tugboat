module Shipr
  module Consumers
    class OutputConsumer
      include Hutch::Consumer
      consume 'job.output'

      def process(message)
        job = Job.find(message[:id])
        job.append_output!(message[:output])
      end
    end
  end
end
