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
      JobCreator.create(repo: job.repo, branch: job.branch, config: job.config)
    end
  end
end
