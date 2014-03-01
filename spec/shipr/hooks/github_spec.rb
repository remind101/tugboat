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

  describe 'POST /' do
    context 'when authenticated' do
      with_authenticated_user

      context 'when the event is a deployment' do
        before do
          header 'X-Github-Event', 'deployment'
        end

        it 'creates a deploy' do
          expect {
            post '/', sha: '1234', name: 'my/repo', payload: JSON.dump(environment: 'staging')
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
            post '/', sha: '1234', name: 'my/repo', payload: JSON.dump(environment: 'staging')
          }.to_not change { Shipr::Job.count }
          verify_response 200
        end
      end
    end

    context 'when not authenticated' do
      it 'returns a 403' do
        post '/', sha: '1234', name: 'my/repo'
        verify_response 403
      end
    end
  end
end
