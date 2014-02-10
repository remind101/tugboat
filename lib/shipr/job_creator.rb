module Shipr
  class JobCreator
    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes
    end

    def self.create(*args)
      new(*args).create
    end

    def create
      trigger
      start
      job
    end

  private

    def job
      @job ||= Job.create(attributes)
    end

    def start
      DeployTask.create(job)
    end

    def trigger
      Shipr.push(job.channel, 'create', job.entity)
    end

  end
end
