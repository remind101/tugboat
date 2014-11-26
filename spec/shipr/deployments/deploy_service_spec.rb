require 'spec_helper'

describe Shipr::Deployments::DeployService do
  let(:deployments_service) { double(Shipr::Deployments::AbstractService) }
  let(:deployer) { double(Shipr::DeployTask) }
  let(:service) { described_class.new deployments_service, deployer }
  
  describe '#create' do
    context 'when the job is created' do
      let(:job) { Shipr::Job.new }

      before do
        deployments_service.stub create: job
      end

      it 'starts the deploy' do
        expect(deployer).to receive(:start).with(job)
        service.create 'remind101/r101-api'
      end
    end
  end
end
