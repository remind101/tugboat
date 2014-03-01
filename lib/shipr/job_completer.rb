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
      update_status
      Shipr.publish('job.complete', id: job.id)
    end

  private

    def trigger
      Shipr.push(job.channel, 'complete', job.entity)
    end

    def update_status
      job.update_status job.success? ? :success : :failure
    end
  end
end
