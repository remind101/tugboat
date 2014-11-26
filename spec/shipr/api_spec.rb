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
end
