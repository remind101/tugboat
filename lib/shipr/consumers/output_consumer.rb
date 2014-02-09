module Shipr
  module Consumers
    class OutputConsumer
      include Hutch::Consumer
      consume 'job.output'

      def process(message)
        p message
      end
    end
  end
end
