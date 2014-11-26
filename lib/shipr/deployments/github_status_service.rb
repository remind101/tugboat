module Shipr::Deployments
  class GitHubStatusService < AbstractService
    attr_reader :deployments_service, :github

    def initialize(deployments_service, github)
      @deployments_service = deployments_service
      @github = github
    end

    # Public: Updates the GitHub Deployment status.
    def create(*args)
      deployments_service.create(*args).tap do |job|
        update_status(job, :pending)
      end
    end

    def completed(job, exit_status)
      deployments_service.completed(job, exit_status).tap do
        update_status(job, job.success? ? :success : :failure)
      end
    end

    def append_output(*args)
      deployments_service.append_output(*args)
    end

    private

    def update_status(job, state)
      github.update_deployment_status(
        job.repo.name,
        job.guid,
        state: state,
        target_url: job.html_url
      )
    end
  end
end
