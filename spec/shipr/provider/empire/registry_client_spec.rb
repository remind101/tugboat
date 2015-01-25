require 'spec_helper'

describe Shipr::Provider::Empire::RegistryClient do
  let(:client) { described_class.new 'https://quay.io', 'foo:bar' }

  describe '#resolve_tag' do
    it 'resolves a tag to an image id' do
      stub_request(:get, 'https://foo:bar@quay.io/v1/repositories/remind101/r101-api/tags/af2a2').to_return(
        status: 200,
        body: '"abcdefg"'
      )
      image_id = client.resolve_tag 'remind101/r101-api', 'af2a2'
      expect(image_id).to eq 'abcdefg'
    end
  end
end
