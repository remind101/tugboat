require 'spec_helper'

describe Shipr::JobCreator do
  let(:attributes) { {} }
  subject(:job_creator) { described_class.new('remind101/shipr', attributes) }

  describe '#create' do
    it 'creates a new job' do
      expect(job_creator.create).to be_a Shipr::Job
    end

    it 'sends a pusher event' do
      Shipr.should_receive(:push)
      job_creator.create
    end

    it 'starts the deploy task' do
      Shipr::DeployTask.should_receive(:create)
      job_creator.create
    end
  end
end
