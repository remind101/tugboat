module Shipr::Queues
  class Update < Base
    queue 'update'

    def processor
      Processor
    end

    class Processor < Struct.new(:message)

      def process
        if output?
          job.append_output!(output)
        elsif exit_status?
          job.complete!(exit_status)
        end
      rescue ActiveRecord::RecordNotFound
        # Record was deleted or something.
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
