class Job < ActiveRecord::Base
  include Grape::Entity::DSL

  # ==============
  # = Delegation =
  # ==============

  class << self
    delegate :redis, to: Shipr
  end

  delegate :redis, to: self

  # =============
  # = Callbacks =
  # =============

  before_validation :set_defaults
  after_create :queue_task

  # =================
  # = Serialization =
  # =================

  serialize :config

  # ===============
  # = Validations =
  # ===============

  validates :repo, presence: true

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
    self.exit_status = exit_status
    self.save!
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
    redis.publish channel, output
    self.output += output
    self.save!
  end

  # Public: Subscribe to the processes output.
  #
  # &block - A block to run when there's new output.
  #
  # Examples
  #
  #   job.on_output do |output|
  #     puts output
  #   end
  def on_output(&block)
    redis.subscribe channel do |on|
      on.message do |channel, output|
        block.call(output)
      end
    end
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

  entity :id, :repo, :branch, :user, :config, :exit_status do
    expose :done?, as: :done
    expose :success?, as: :success
  end

private
  
  def channel
    "#{self.class.to_s.downcase}:#{id}:output"
  end

  def set_defaults
    self.branch ||= 'master'
    self.config ||= { 'ENVIRONMENT' => 'production' }
    self.output ||= ''
  end

  def queue_task
    DeployTask.create(self)
  end

  class DeployTask < Struct.new(:job)
    # ==============
    # = Delegation =
    # ==============

    delegate :workers, to: Shipr
    delegate :tasks, to: :workers
    delegate \
      :id,
      :repo,
      :branch,
      :config,
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
      { id: id, iron_mq: iron_mq, env: env }
    end

    def iron_mq
      { credentials: {
          token: ENV['IRON_MQ_TOKEN'],
          project_id: ENV['IRON_MQ_PROJECT_ID'] } }
    end

    def env
      config.merge \
        'REPO'     => repo,
        'BRANCH'   => branch,
        'SSH_KEY'  => ENV['SSH_KEY']
    end

  end

end
