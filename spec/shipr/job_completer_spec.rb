require 'spec_helper'

describe Shipr::JobCompleter do
  let(:repo) { Shipr::Repo.create! name: 'remind101/shipr' }
  let(:job) { Shipr::Job.create! repo: repo }
  let(:exit_status) { 1 }
  subject(:job_completer) { described_class.new(job, exit_status) }

  describe '#complete' do
    it 'sets the exit status' do
      expect { job_completer.complete }.to change { job.exit_status }.to(1)
    end

    it 'sends a push event' do
      Shipr.should_receive(:push).with(kind_of(String), 'complete', kind_of(Shipr::Job::Entity))
      job_completer.complete
    end

    it 'publishes a message' do
      Shipr.stub(:push)
      Shipr.should_receive(:publish).with('job.complete', id: job.id)
      job_completer.complete
    end
  end
end
