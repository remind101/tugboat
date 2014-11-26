require 'spec_helper'

describe Shipr::Deployments::PushedService do
  let(:deployments_service) { Shipr::Deployments::BaseService.new }
  let(:pusher_service) { double(Pusher) }
  let(:service) { described_class.new deployments_service, pusher_service }
  
  describe '#create' do
    context 'when the job is created' do
      it 'triggers a pusher event' do
        expect(pusher_service).to receive(:trigger).with(kind_of(String), :create, kind_of(Hash))
        service.create 'remind101/r101-api'
      end
    end
  end

  describe '#completed' do
    let(:job) { deployments_service.create('remind101/r101-api') }

    context 'when the job is created' do
      it 'triggers a pusher event' do
        expect(pusher_service).to receive(:trigger).with(job.channel, :complete, kind_of(Hash))
        service.completed job, -1
      end
    end
  end

  describe '#append_output' do
    let(:job) { deployments_service.create('remind101/r101-api') }

    context 'when the job is created' do
      it 'triggers a pusher event' do
        expect(pusher_service).to receive(:trigger).with(job.channel, :output, id: job.id, output: 'hello')
        service.append_output job, 'hello'
      end
    end
  end
end
