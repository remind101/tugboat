
require 'spec_helper'

describe Shipr::Provider::Empire::EmpireClient do
  let(:client) { described_class.new 'https://empire.remind.com' }

  describe '#create_deploy' do
    it 'post a url' do
      stub_request(:post, 'https://empire.remind.com/v1/deploys').with(
        body: '{"image":{"id":"1234","repo":"remind101/r101-api"}}'
      )
      client.create_deploy id: '1234', repo: 'remind101/r101-api'
    end
  end
end
