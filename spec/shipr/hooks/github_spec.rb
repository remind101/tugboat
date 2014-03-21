require 'spec_helper'

describe Shipr::Hooks::GitHub do
  include ApiExampleGroup

  let(:current_user) { 'foo@bar.com' }

  def app
    Rack::Builder.new do
      use Rack::Session::Cookie, secret: SecureRandom.hex
      run Shipr::Hooks::GitHub
    end
  end

  before do
    header 'Content-Type', 'application/json'
  end

  describe 'POST /' do
    context 'when authenticated' do
      before do
        warden.stub(authenticate!: true)
      end

      context 'when the event is a deployment' do
        before do
          header 'X-Github-Event', 'deployment'
        end

        it 'creates a deploy' do
          expect {
            post '/', { id: '1', sha: '1234', name: 'my/repo', payload: { environment: 'staging' } }.to_json
          }.to change { Shipr::Job.count }.by(1)
          verify_response 200
        end
      end

      context 'when the event is a ping' do
        before do
          header 'X-Github-Event', 'ping'
        end

        it 'does not create a deploy' do
          expect {
            post '/', { id: '1', sha: '1234', name: 'my/repo', payload: { environment: 'staging' } }.to_json
          }.to_not change { Shipr::Job.count }
          verify_response 200
        end
      end
    end

    context 'when not authenticated' do
      before do
        warden.stub(:authenticate!).and_throw(:warden)
      end

      it 'returns a 403' do
        expect {
          post '/', { id: '1', sha: '1234', name: 'my/repo' }.to_json
        }.to throw_symbol :warden
      end
    end
  end
end
