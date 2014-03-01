require 'spec_helper'
require 'securerandom'

describe Shipr::API do
  include ApiExampleGroup

  def app
    Rack::Builder.new do
      use Rack::Session::Cookie, secret: SecureRandom.hex
      run Shipr::API
    end
  end

  let(:current_user) { 'foo@bar.com' }

  describe 'GET /deploys' do
    with_authenticated_user

    it 'returns all jobs' do
      get '/deploys'
      verify_response 200
    end
  end

  describe 'GET /unauthenticated' do
    it 'does something' do
      get '/unauthenticated' do
        verify_response 401
        expect(last_response.headers['WWW-Authenticate']).to eq %(Basic realm="API Authentication")
      end
    end
  end

  describe 'POST /deploys/:id/restart' do
    with_authenticated_user

    let(:job) { create :job, sha: '1234' }

    it 'restarts the job' do
      post "/deploys/#{job.id}/restart"
      verify_response 200
    end
  end
end
