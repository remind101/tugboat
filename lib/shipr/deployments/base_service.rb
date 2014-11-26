module Shipr::Deployments
  class BaseService < AbstractService
    def create(repo_name, attributes = {})
      raise ArgumentError, "Name is required" unless repo_name
      repo = Shipr::Repo.where(name: repo_name).first_or_create!
      repo.jobs.create!(attributes.delete_if { |k,v| v.nil? })
    end

    def completed(job, exit_status)
      job.update_attributes!(exit_status: exit_status)
    end

    def append_output(job, output)
      job.output += output
      job.save!
    end
  end
end
