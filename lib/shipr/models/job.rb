require 'uuid'

class Job
  extend ActiveModel::Callbacks
  include Virtus

  attribute :uuid, String
  attribute :repo, String
  attribute :environment, String

  # ==============
  # = Delegation =
  # ==============

  class << self
    delegate :workers, :redis,   to: Shipr
    delegate :tasks,             to: :workers
  end

  delegate :iron_worker, :redis, to: self
  delegate :tasks,               to: self

  # =============
  # = Callbacks =
  # =============

  define_model_callbacks :save, :create

  before_create do
    self.uuid ||= UUID.new.generate
  end

  after_create do
    tasks.create 'Deploy', task_params
  end

  # ===========
  # = Methods =
  # ===========

  def self.create(*args)
    new(*args).tap do |job|
      job.run_callbacks :create do
        job.save
      end
    end
  end

  def save
    run_callbacks :save do
      redis.set key, attributes
    end
  end

private

  def task_params
    { uuid: uuid, env: task_env }
  end

  def task_env
    { 'REPO'               => repo,
      'ENVIRONMENT'        => environment,
      'SSH_KEY'            => ENV['SSH_KEY'],
      'IRON_MQ_PROJECT_ID' => ENV['IRON_MQ_PROJECT_ID'],
      'IRON_MQ_TOKEN'      => ENV['IRON_MQ_TOKEN'] }
  end

  def key
    "#{self.class.to_s}:#{uuid}"
  end

end
