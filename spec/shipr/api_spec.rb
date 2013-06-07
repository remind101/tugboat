require 'spec_helper'

describe Shipr::API do
  include Rack::Test::Methods

  def app
    Rack::Builder.new do
      use Rack::Session::Cookie
      use Warden::Manager do |manager|
        manager.default_strategies :basic
      end
      run Shipr::API
    end
  end

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
