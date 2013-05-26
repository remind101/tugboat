require 'spec_helper'

describe Job do
  let(:redis) { Redis.any_instance }
  let(:iron_worker) { IronWorkerNG::Client.any_instance }

  before do
    iron_worker.stub_chain :tasks, :create
  end

  describe '#create' do
    subject(:job) { described_class.create(args) }

    let(:args) do
      { repo: 'git@github.com:foo/bar.git',
        environment: 'staging' }
    end

    it 'sets a uuid' do
      expect(job.uuid).to_not be_empty
    end

    it 'persists the job to redis' do
      Job.any_instance.should_receive(:save)
      job
    end
  end

  describe '.save' do
    subject(:save) { job.save }

    let(:job) { described_class.new(uuid: 'foo', repo: 'bar') }

    it 'sets a key in redis to the attributes' do
      redis.should_receive(:set)
        .with('Job:foo', uuid: 'foo', repo: 'bar', treeish: 'master', environment: 'production')
      save
    end
  end
end
