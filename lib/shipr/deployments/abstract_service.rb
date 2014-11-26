module Shipr::Deployments
  class AbstractService
    # Public: Create a new deployment.
    #
    # repo_name  - The name of the repo.
    # attributes - A Hash of attributes.
    #
    # Returns a Shipr::Job.
    def create(repo_name, attributes = {})
      raise NotImplementedError
    end

    # Public: Mark the job as complete.
    #
    # job         - A Shipr::Job instance.
    # exit_status - The integer exit status.
    #
    # Returns nothing.
    def completed(job, exit_status)
      raise NotImplementedError
    end

    # Public: Add a line of output to the job.
    #
    # job    - A Shipr::Job instance.
    # output - A String of output.
    # 
    # Returns nothing.
    def append_output(job, output)
      raise NotImplementedError
    end
  end
end
