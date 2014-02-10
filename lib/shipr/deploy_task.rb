module Shipr
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
