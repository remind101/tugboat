module Shipr::Deployments
  class PushedService < AbstractService
    attr_reader :deployments_service, :pusher_service

    def initialize(deployments_service, pusher_service)
      @deployments_service = deployments_service
      @pusher_service = pusher_service
    end

    # Public: Sends a pusher event after creating the Job.
    def create(*args)
      deployments_service.create(*args).tap do |job|
        trigger_entity(job, :create)
      end
    end

    def completed(job, exit_status)
      deployments_service.completed(job, exit_status).tap do
        trigger_entity(job, :complete)
      end
    end

    def append_output(job, output)
      deployments_service.append_output(job, output).tap do
        trigger(job, :output, id: job.id, output: output)
      end
    end

    private

    def trigger(job, event, data)
      pusher_service.trigger(job.channel, event, data)
    end

    def trigger_entity(job, event)
      trigger(job, event, Shipr::Entities::Job.represent(job).serializable_hash)
    end
  end
end
