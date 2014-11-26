require 'spec_helper'

describe Shipr::Provider::IronWorker do
  let(:tasks) { double 'tasks' }
  let(:client) { double IronWorkerNG::Client, tasks: tasks }
  let(:service) { described_class.new client }

  describe '#start' do
    let(:repo) { Shipr::Repo.new name: 'remind101/r101-api' }
    let(:job) { Shipr::Job.new repo: repo, sha: 1234 }

    it 'creates a deploy task' do
      expect(tasks).to receive(:create).with(
        'Deploy',
        id: job.id,
        rabbitmq: {
          url: nil,
          exchange: 'hutch'
        },
        env: {
          'ENVIRONMENT'   => 'production',
          'FORCE'         => '0',
          'REPO'          => 'git@github.com:remind101/r101-api.git',
          'SHA'           => '1234',
          'SSH_KEY'       => nil,
          'DEPLOY_SCRIPT' => nil
        }
      )
      service.start(job)
    end
  end
end
