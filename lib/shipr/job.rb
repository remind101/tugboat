module Shipr
  class Job
    include Mongoid::Document
    include Grape::Entity::DSL
    store_in collection: 'jobs'

    belongs_to :repo

    field :guid, type: Integer
    field :sha, type: String
    field :environment, type: String, default: 'production'
    field :force, type: Boolean, default: false
    field :description, type: String, default: ''
    field :config, type: Hash, default: {}
    field :output, type: String, default: ''
    field :exit_status, type: Integer
    field :script, type: String

    def id
      _id.to_s
    end

    # ===========
    # = Methods =
    # ===========
    
    # Public: Mark the job is complete, with the exit status of the process.
    #
    # exit_status - Integer exit status of the deploy command.
    #
    # Examples
    #
    #   job.complete!(0)
    #   # => true
    def complete!(exit_status)
      JobCompleter.complete(self, exit_status)
    end

    # Public: Append lines of output from the process.
    #
    # output - String of text to append. Can 
    #
    # Examples
    #
    #   job.append_output!("hello world")!
    #   # => true
    def append_output!(output)
      JobOutputAppender.append(self, output)
    end

    # Public: Wether the job has completed or not.
    #
    # Examples
    #
    #   job.done?
    #   # => true
    def done?
      exit_status.present?
    end

    # Public: Wether the job is successful or not. In other words, whether or not
    # the exit status is 0.
    #
    # Examples
    #
    #   job.success?
    #   # => false
    def success?
      exit_status == 0
    end

    def script
      super || Shipr.default_script
    end

    # Public: Restart this job.
    #
    # Returns new Job.
    def restart!
      JobRestarter.restart(self)
    end

    # Public: Update the deployment status on github.
    def update_status(status)
      Shipr.github.update_deployment_status(
        repo.name,
        guid,
        state: status
      )
    end

    # Public: Channel where pusher messages should be sent.
    # 
    # Returns String.
    def channel
      "private-job-#{id}"
    end

    entity :id, :sha, :force, :environment, :config, :exit_status do
      expose :done?, as: :done
      expose :success?, as: :success
      expose :output, if: :include_output
    end
  end
end
