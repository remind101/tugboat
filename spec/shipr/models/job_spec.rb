require 'spec_helper'

describe Job do
  let(:redis) { Redis.any_instance }
  let(:iron_worker) { IronWorkerNG::Client.any_instance }
  subject(:job) { described_class.create(repo: 'git@github.com:ejholmes/shipr.git') }

  before do
    iron_worker.stub_chain :tasks, :create
  end

  describe '#create' do
    it { should be_valid }
    its(:branch) { should eq 'master' }
    its(:config) { should eq('ENVIRONMENT' => 'production') }
    its(:output) { should eq '' }
  end

  describe '.complete!' do
    before do
      job.complete!(-1)
    end

    its(:exit_status) { should eq -1 }
  end

  describe '.append_output!' do
    before do
      job.append_output!('hello')
      job.append_output!('world')
    end

    its(:output) { should eq 'helloworld' }
  end
end
