module Shipr
  class DeployTask < Struct.new(:job)
    # ==============
    # = Delegation =
    # ==============

    delegate :workers, to: :'Shipr'
    delegate :tasks, to: :workers
    delegate \
      :id,
      :name,
      :sha,
      :environment,
      :force,
      :config,
      :script,
      :repo,
      to: :job

    delegate \
      :clone_url,
      to: :repo

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
        'ENVIRONMENT'   => environment,
        'FORCE'         => force ? '1' : '0',
        'REPO'          => clone_url,
        'SHA'           => sha,
        'SSH_KEY'       => ENV['SSH_KEY'],
        'DEPLOY_SCRIPT' => script
    end

  end
end
