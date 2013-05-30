require 'spec_helper'

describe Shipr::API do
  include Rack::Test::Methods

  let(:app) { Shipr.app }
  let(:current_user) { 'foo@bar.com' }
  let(:body) { JSON.parse(last_response.body) }

  describe 'POST /deploy' do
    with_authenticated_user

    let(:attrs) do
      { repo: 'git@github.com:foo/bar.git' }
    end

    it 'creates a job' do
      Job.should_receive(:create).with(attrs)
      post '/deploy', attrs
      puts last_response.body
      expect(last_response.status).to eq 201
    end
  end
end
