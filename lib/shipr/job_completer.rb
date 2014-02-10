module Shipr
  class JobCompleter
    attr_reader :job, :exit_status

    def initialize(job, exit_status)
      @job = job
      @exit_status = exit_status
    end

    def self.complete(*args)
      new(*args).complete
    end

    def complete
      job.update_attributes!(exit_status: exit_status)
      trigger
      Shipr.publish('job.complete', id: job.id)
    end

  private

    def trigger
      Shipr.push(job.channel, 'complete', job.entity)
    end
  end
end
