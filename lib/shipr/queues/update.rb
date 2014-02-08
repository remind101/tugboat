module Shipr::Queues
  class Update < Base
    queue 'update'

    def process(message)
      Processor.new(message).process
    end

  private

    class Processor < Struct.new(:message)

      def process
        if output?
          job.append_output!(output)
        elsif exit_status?
          job.complete!(exit_status)
        end
      end

    private

      delegate \
        :id,
        :exit_status,
        :exit_status?,
        :output,
        :output?,
        to: :message

      def job
        @job ||= Job.find(id)
      end

    end
  end
end
