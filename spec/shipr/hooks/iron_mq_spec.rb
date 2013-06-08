require 'spec_helper'

describe Shipr::Hooks::IronMQ do
  include Rack::Test::Methods

  def app
    Shipr::Hooks::IronMQ
  end

  describe 'POST /' do
    let(:job) { double(Job, id: '1234') }
    
    context 'when the job exists' do
      before do
        Job.stub find: job
      end

      context 'with some output' do
        it 'updates the job' do
          job.should_receive(:append_output!).with('hello')
          post '/', id: job.id, output: 'hello'
          expect(last_response.status).to eq 200
          expect(last_response.body).to eq '{}'
        end
      end

      context 'with a status' do
        it 'updates the job' do
          job.should_receive(:complete!).with(1)
          post '/', id: job.id, exit_status: 1
          expect(last_response.status).to eq 200
          expect(last_response.body).to eq '{}'
        end
      end
    end

    context 'when the job does not exist' do
      it 'responds with a 200 response' do
        post '/', id: '123456'
        expect(last_response.status).to eq 200
      end
    end
  end
end
