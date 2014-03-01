module Shipr
  class JobCreator
    attr_reader :name
    attr_reader :attributes

    def initialize(name, attributes)
      @name = name
      @attributes = attributes
    end

    def self.create(*args)
      new(*args).create
    end

    def create
      trigger
      start
      update_status
      job
    end

  private

    def repo
      @repo ||= Repo.where(name: name).first_or_create
    end

    def job
      @job ||= repo.jobs.create(attributes)
    end

    def start
      DeployTask.create(job)
    end

    def update_status
      job.update_status(:pending)
    end

    def trigger
      Shipr.push(job.channel, 'create', job.entity)
    end

  end
end
