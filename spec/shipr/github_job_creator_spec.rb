require 'spec_helper'

describe Shipr::GitHubJobCreator do
  let(:params) do
    { name: 'remind101/shipr',
      sha: '1234',
      description: 'My topic branch',
      payload: { environment: 'staging', config: { 'FOO' => 'BAR' } } }
  end

  describe '.create' do
    subject { described_class.create(params) }

    context 'when payload is provided' do
      its(:repo)        { should be_a Shipr::Repo }
      its(:sha)         { should eq '1234' }
      its(:environment) { should eq 'staging' }
      its(:config)      { should eq('FOO' => 'BAR') }
    end

    context 'when payload is nil' do
      before do
        params[:payload] = nil
      end

      its(:repo) { should be_a Shipr::Repo }
      its(:sha)  { should eq '1234' }
    end
  end
end
