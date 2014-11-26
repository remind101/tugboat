require 'spec_helper'

describe Shipr::Deployments::DeployService do
  let(:deployments_service) { double(Shipr::Deployments::AbstractService) }
  let(:provider) { double(Shipr::Provider::Base) }
  let(:service) { described_class.new deployments_service, provider }
  
  describe '#create' do
    context 'when the job is created' do
      let(:job) { Shipr::Job.new }

      before do
        deployments_service.stub create: job
      end

      it 'starts the deploy' do
        expect(provider).to receive(:start).with(job)
        service.create 'remind101/r101-api'
      end
    end
  end
end
