require 'spec_helper'

describe Shipr::Deployments::BaseService do
  let(:service) { described_class.new }

  describe '#create' do
    let(:name) { 'remind101/r101-api' }

    context 'when the repo exists' do
      before do
        Shipr::Repo.create(name: name)
      end

      it 'does not create a new repo' do
        expect {
          service.create name
        }.to_not change { Shipr::Repo.count }
      end

      it 'creates a new job' do
        expect {
          service.create name
        }.to change { Shipr::Job.count }.by(1)
      end
    end

    context 'when the repo does not exist' do
      it 'creates a new repo' do
        expect {
          service.create name
        }.to change { Shipr::Repo.count }.by(1)
      end
    end
  end

  describe '#completed' do
    let(:name) { 'remind101/r101-api' }
    let(:job) { service.create(name) }

    it 'marks the job as complete' do
      expect {
        service.completed job, -1
      }.to change { job.exit_status }.to(-1)
    end
  end

  describe '#append_output' do
    let(:name) { 'remind101/r101-api' }
    let(:job) { service.create(name) }

    it 'adds the output' do
      expect {
        service.append_output job, 'hello'
        service.append_output job, 'world'
      }.to change { job.output }.to('helloworld')
    end
  end
end
