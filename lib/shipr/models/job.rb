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
    delegate :iron_worker, :redis, to: Shipr
    delegate :tasks,               to: :iron_worker
  end

  delegate :iron_worker, :redis,   to: self
  delegate :tasks,                 to: self

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
    job = new(*args)
    job.run_callbacks :create do
      job.save
    end
    job
  end

  def save
    run_callbacks :save do
      redis.set key, attributes
    end
  end

private

  def task_params
    { uuid: uuid, env: attributes.slice(:repo, :environment) }
  end

  def key
    "#{self.class.to_s}:#{uuid}"
  end

end
