module Shipr
  class JobRestarter
    attr_reader :job

    def initialize(job)
      @job = job
    end

    def self.restart(*args)
      new(*args).restart
    end

    def restart
      JobCreator.create(job.repo.name,
        sha: job.sha,
        environment: job.environment,
        config: job.config.dup,
        notify: job.notify.dup
      )
    end
  end
end
