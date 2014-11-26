module Shipr::Provider
  class IronWorker < Base
    TASK = 'Deploy'.freeze

    attr_reader :client

    def initialize(client = IronWorkerNG::Client.new)
      @client = client
    end

    def start(job)
      tasks.create TASK,
        id: job.id,
        rabbitmq: {
          url:      ENV['RABBITMQ_URL'],
          exchange: 'hutch'
        },
        env: job.config.merge(
          'ENVIRONMENT'   => job.environment,
          'FORCE'         => job.force ? '1' : '0',
          'REPO'          => job.repo.clone_url,
          'SHA'           => job.sha,
          'SSH_KEY'       => Shipr.configuration.ssh_key,
          'DEPLOY_SCRIPT' => job.script
        )
    end

    private

    def tasks
      client.tasks
    end
  end
end
