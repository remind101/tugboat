require 'uuid'

class Job
  extend ActiveModel::Callbacks
  include Virtus

  attribute :uuid, String
  attribute :repo, String
  attribute :treeish, String, default: 'master'
  attribute :environment, String, default: 'production'

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

  define_model_callbacks :save, :create

  before_create do
    self.uuid ||= UUID.new.generate
  end

  after_create do
    DeployTask.create(self)
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

  def key
    "#{self.class.to_s}:#{uuid}"
  end

  class DeployTask < Struct.new(:job)
    # ==============
    # = Delegation =
    # ==============

    delegate :workers, to: Shipr
    delegate :tasks, to: :workers
    delegate \
      :uuid,
      :repo,
      :treeish,
      :environment,
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
      { uuid: uuid, iron_mq: iron_mq, env: env }
    end

    def iron_mq
      { credentials: {
          token: ENV['IRON_MQ_TOKEN'],
          project_id: ENV['IRON_MQ_PROJECT_ID'] } }
    end

    def env
      { 'REPO'        => repo,
        'TREEISH'     => treeish,
        'ENVIRONMENT' => environment,
        'SSH_KEY'     => ENV['SSH_KEY'] }
    end

  end

end
