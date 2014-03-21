require 'spec_helper'

describe Shipr::JobRestarter do
  let(:job) { create :job, sha: 'abc', config: { foo: 'bar' } }
  subject(:job_restarter) { described_class.new(job) }

  describe '#restart' do
    subject(:restarted) { job_restarter.restart }

    its(:id)          { should_not eq job.id }
    its(:repo)        { should eq job.repo }
    its(:sha)         { should eq job.sha }
    its(:environment) { should eq job.environment }
    its(:config)      { should eq job.config }
  end
end
