require 'spec_helper'

describe Shipr::JobRestarter do
  let(:job) { Shipr::Job.create repo: 'foo', branch: 'bar', config: { foo: 'bar' } }
  subject(:job_restarter) { described_class.new(job) }

  describe '#restart' do
    subject(:restarted) { job_restarter.restart }

    its(:id) { should_not eq job.id }
    its(:repo) { should eq job.repo }
    its(:branch) { should eq job.branch }
    its(:config) { should eq job.config }
  end
end
