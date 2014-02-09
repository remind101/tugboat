class Job
  include Mongoid::Document
  include Grape::Entity::DSL
  store_in collection: 'jobs'

  field :repo, type: String
  field :branch, type: String, default: 'master'
  field :config, type: Hash, default: { 'ENVIRONMENT' => 'production' }
  field :output, type: String, default: ''
  field :exit_status, type: Integer
  field :script, type: String

  def id
    _id.to_s
  end

  # =============
  # = Callbacks =
  # =============

  define_model_callbacks :complete

  after_create :queue_task

  after_create do
    trigger 'create', entity
  end

  after_complete do
    trigger 'complete', entity
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
    run_callbacks :complete do
      self.exit_status = exit_status
      save!
    end
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
    self.output += output
    trigger 'output', id: id, output: output
    save!
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
    Job.create(repo: repo, branch: branch, config: config)
  end

  entity :id, :repo, :branch, :user, :config, :exit_status do
    expose :done?, as: :done
    expose :success?, as: :success
    expose :output, if: :include_output
  end

private

  def trigger(event, data)
    Hutch.publish('pusher.push', channel: channel, event: event, data: data)
  end

  def channel
    "private-#{self.class.to_s.downcase}-#{id}"
  end

  def queue_task
    DeployTask.create(self)
  end

  class DeployTask < Struct.new(:job)
    # ==============
    # = Delegation =
    # ==============

    delegate :workers, to: :'Shipr'
    delegate :tasks, to: :workers
    delegate \
      :id,
      :repo,
      :branch,
      :config,
      :script,
      to: :job

    # ===========
    # = Methods =
    # ===========

    def self.create(*args); new(*args).create end

    def create
      tasks.create 'Deploy', params
    end

  private

    def params
      { id: id, rabbitmq: rabbitmq, env: env }
    end

    def rabbitmq
      { url: ENV['RABBITMQ_URL'], exchange: 'hutch' }
    end

    def env
      config.merge \
        'REPO'          => repo,
        'BRANCH'        => branch,
        'SSH_KEY'       => ENV['SSH_KEY'],
        'DEPLOY_SCRIPT' => script
    end

  end

end
