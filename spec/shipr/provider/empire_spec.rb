require 'spec_helper'

describe Shipr::Provider::Empire do
  let(:empire_client) { double(Shipr::Provider::Empire::EmpireClient)}
  let(:registry_client) { double(Shipr::Provider::Empire::RegistryClient) }
  let(:service) { described_class.new empire_client, registry_client }

  describe '#start' do
    let(:repo) { Shipr::Repo.new name: 'remind101/r101-api' }
    let(:job) { Shipr::Job.new repo: repo, sha: 1234 }

    it 'creates a deploy task' do
      expect(registry_client).to receive(:resolve_tag).with('remind101/r101-api', '1234').and_return('abcdefg')
      expect(empire_client).to receive(:create_deploy).with(id: 'abcdefg', repo: 'remind101/r101-api')
      service.start(job)
    end
  end
end
