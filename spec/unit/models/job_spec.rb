require 'spec_helper'

describe Job do
  let(:iron_worker) { Shipr.workers }
  subject(:job) { described_class.create(repo: 'git@github.com:ejholmes/shipr.git') }

  before do
    iron_worker.stub_chain :tasks, :create
  end

  describe '#create' do
    it { should be_valid }
    its(:branch) { should eq 'master' }
    its(:config) { should eq('ENVIRONMENT' => 'production') }
    its(:output) { should eq '' }
    its(:script) { should eq nil }
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

  describe '.done?' do
    subject { job.done? }

    context 'when the exit status is present' do
      before do
        job.exit_status = -1
      end

      it { should be_true }
    end

    context 'when the exit status is not present' do
      it { should be_false }
    end
  end

  describe '.success?' do
    subject { job.success? }

    context "when the exit_status is 0" do
      before do
        job.exit_status = 0
      end

      it { should be_true }
    end
  end
end
