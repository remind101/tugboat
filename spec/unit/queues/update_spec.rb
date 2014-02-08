require 'spec_helper'

describe Shipr::Queues::Update do
  let(:queue) { described_class.new }

  describe '#process' do
    let(:job) { double(Job) }
    let(:message) { double('message', id: '1234', output?: false, exit_status?: false) }

    before do
      Job.stub(:find).with(message.id).and_return(job)
    end

    describe 'output messages' do
      before do
        message.stub \
          output?: true,
          output: "log line\n"
      end

      it 'appends the output' do
        job.should_receive(:append_output!).with(message.output)
        queue.process message
      end
    end

    describe 'completion messages' do
      before do
        message.stub \
          exit_status?: true,
          exit_status: 1
      end

      it 'complets the job' do
        job.should_receive(:complete!).with(message.exit_status)
        queue.process message
      end
    end
  end
end
