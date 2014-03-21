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

  before do
    warden.stub(authenticate!: true)
  end

  describe 'GET /deploys' do
    it 'returns all jobs' do
      get '/deploys'
      verify_response 200
    end
  end

  describe 'POST /deploys/:id/restart' do
    let(:job) { create :job, sha: '1234' }

    it 'restarts the job' do
      post "/deploys/#{job.id}/restart"
      verify_response 200
    end
  end
end
