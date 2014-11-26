module Shipr::Deployments
  class DeployService < AbstractService
    attr_reader :deployments_service, :deployer

    def initialize(deployments_service, deployer)
      @deployments_service = deployments_service
      @deployer = deployer
    end

    # Public: Create a new deployment.
    def create(*args)
      deployments_service.create(*args).tap do |job|
        deployer.start(job)
      end
    end

    def completed(*args)
      deployments_service.completed(*args)
    end

    def append_output(*args)
      deployments_service.append_output(*args)
    end
  end
end
