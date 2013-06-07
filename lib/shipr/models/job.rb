require 'uuid'

class Job
  extend ActiveModel::Callbacks
  include Virtus

  attribute :uuid, String
  attribute :user, String
  attribute :repo, String
  attribute :branch, String, default: 'master'
  attribute :config, Hash, default: { 'ENVIRONMENT' => 'production' }
  attribute :output, String, default: ''
  attribute :status, Integer

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

  define_model_callbacks :save, :create, :complete

  before_create do
    self.uuid ||= UUID.new.generate
  end

  after_create do
    DeployTask.create(self)
  end

  # ===========
  # = Methods =
  # ===========

  def self.find(uuid)
    params = redis.get(key(uuid))
    new(JSON.parse(params))
  end

  def self.create(*args)
    new(*args).tap do |job|
      job.run_callbacks :create do
        job.save
      end
    end
  end

  def save
    run_callbacks :save do
      redis.set key, attributes.to_json
    end
  end

  def complete(status)
    run_callbacks :complete do
      job.status = status
      job.save
    end
  end

  def append_output(line)
    redis.publish pubsub_key, { 'line' => line.strip }.to_json
    self.output << line
    save
  end

  def on_output(&block)
    redis.subscribe pubsub_key do |on|
      on.message do |channel, msg|
        data = JSON.parse(msg)
        block.call(data['line'])
      end
    end
  end

private

  def self.key(uuid)
    "#{self.to_s}:#{uuid}"
  end

  def key
    self.class.key(uuid)
  end

  def pubsub_key
    "#{key}:pubsub"
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
      { uuid: uuid, iron_mq: iron_mq, env: env }
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
