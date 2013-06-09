require 'spec_helper'
require 'securerandom'

describe Shipr::API do
  include Rack::Test::Methods

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
      expect(last_response.status).to eq 200
    end
  end

  describe 'GET /unauthenticated' do
    it 'does something' do
      get '/unauthenticated' do
        expect(last_response.status).to eq 401
        expect(last_response.headers['WWW-Authenticate']).to eq %(Basic realm="API Authentication")
      end
    end
  end

  describe 'POST /deploys' do
    with_authenticated_user

    let(:attrs) do
      { repo: 'git@github.com:foo/bar.git' }
    end

    it 'creates a job' do
      Job.should_receive(:create).with(attrs)
      post '/deploys', attrs
      expect(last_response.status).to eq 201
    end
  end

  describe 'GET /deploys/:id' do
    with_authenticated_user

    it 'retrives the job' do
      get '/deploys', id: '1234'
    end
  end
end
