require 'spec_helper'

describe Shipr::JobOutputAppender do
  let(:repo) { Shipr::Repo.create! name: 'remind101/shipr' }
  let(:job) { Shipr::Job.create! repo: repo }
  let(:output) { "Foobar\n" }
  subject(:job_output_appender) { described_class.new(job, output) }

  describe '#append' do
    it 'appends output to the job' do
      expect { job_output_appender.append }.to change { job.output }
    end

    it 'sends a pusher event' do
      Shipr.should_receive(:push).with(kind_of(String), 'output', id: job.id, output: output)
      job_output_appender.append
    end
  end
end
