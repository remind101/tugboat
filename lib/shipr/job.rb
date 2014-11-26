module Shipr
  class Job
    include Mongoid::Document
    store_in collection: 'jobs'

    belongs_to :repo

    field :guid, type: Integer
    field :sha, type: String
    field :ref, type: String
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

    # Public: Channel where pusher messages should be sent.
    # 
    # Returns String.
    def channel
      "private-job-#{id}"
    end

    # Public: Location where the build can be viewed.
    #
    # Returns String.
    def html_url
      "#{Shipr.configuration.base_url}/deploys/#{id}"
    end
  end
end
