require 'spec_helper'

describe Shipr::Deployments::GitHubStatusService do
  let(:deployments_service) { Shipr::Deployments::BaseService.new }
  let(:github) { double(Shipr::GitHub::Client) }
  let(:service) { described_class.new deployments_service, github }

  describe '#create' do
    let(:name) { 'remind101/r101-api' }

    context 'when the job is created' do
      it 'updates the github deployment status' do
        expect(github).to receive(:update_deployment_status).with(
          name,
          1234,
          state: :pending,
          target_url: kind_of(String)
        )
        service.create name, guid: 1234
      end
    end
  end

  describe '#completed' do
    let(:name) { 'remind101/r101-api' }
    let(:job) { deployments_service.create name, guid: 1234 }

    context 'when the job exited successfully' do
      it 'publishes a success event' do
        expect(github).to receive(:update_deployment_status).with(
          name,
          1234,
          state: :success,
          target_url: kind_of(String)
        )
        service.completed job, 0
      end
    end

    context 'when the job did not exit successfully' do
      it 'publishes a failure event' do
        expect(github).to receive(:update_deployment_status).with(
          name,
          1234,
          state: :failure,
          target_url: kind_of(String)
        )
        service.completed job, -1
      end
    end
  end
end
