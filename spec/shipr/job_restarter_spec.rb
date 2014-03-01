require 'spec_helper'

describe Shipr::JobRestarter do
  let(:repo) { Shipr::Repo.create name: 'remind101/shipr' }
  let(:job) { Shipr::Job.create repo: repo, sha: 'abc', config: { foo: 'bar' }, notify: ['http://webhook.test'] }
  subject(:job_restarter) { described_class.new(job) }

  describe '#restart' do
    subject(:restarted) { job_restarter.restart }

    its(:id)          { should_not eq job.id }
    its(:repo)        { should eq job.repo }
    its(:sha)         { should eq job.sha }
    its(:environment) { should eq job.environment }
    its(:config)      { should eq job.config }
    its(:notify)      { should eq job.notify }
  end
end
