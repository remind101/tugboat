require 'spec_helper'

describe Shipr::API do
  include Rack::Test::Methods

  let(:app)  { described_class }
  let(:body) { JSON.parse(last_response.body) }

  describe 'POST /deploy' do
    let(:attrs) do
      { repo: 'git@github.com:foo/bar.git',
        environment: 'staging' }
    end

    it 'creates a job' do
      Job.should_receive(:create).with(attrs)
      post '/deploy', attrs
      expect(last_response.status).to eq 201
    end
  end
end
