require 'spec_helper'

describe Shipr::Notifiers::Slack do
  let(:account) { 'foobar' }
  let(:token) { '1234' }
  let(:payload) { Hashie::Mash.new(input) }
  subject(:notifier) { described_class.new(payload) }

  before do
    ENV['SLACK_ACCOUNT'] = account
    ENV['SLACK_TOKEN']   = token
  end

  after do
    ENV.delete('SLACK_ACCOUNT')
    ENV.delete('SLACK_TOKEN')
  end

  describe '#notify' do
    before do
      stub_request(:post, "https://#{account}.slack.com/services/hooks/incoming-webhook?token=#{token}")
        .with(body: "payload=#{JSON.dump(attachments: [output])}")
    end

    context 'when the deployment is pending' do
      let(:input) do
        { state: 'pending',
          target_url: 'http://shipr.test/deploys/1',
          name: 'shipr-test/test-repo',
          sha: '5f834de43d24c20ae761f8b4a6fd8a980928b96b',
          payload: {
            environment: 'production'
          } }
      end

      let(:output) do
        { fallback: 'Deploying shipr-test/test-repo@5f834d to production: http://shipr.test/deploys/1',
          color: '#ff0',
          fields: [
            { value: 'Deploying shipr-test/test-repo@5f834d to production: http://shipr.test/deploys/1' }
          ] }
      end

      it 'sends the proper payload' do
        notifier.notify
      end
    end

    context 'when the deployment is successful' do
      let(:input) do
        { state: 'success',
          target_url: 'http://shipr.test/deploys/1',
          name: 'shipr-test/test-repo',
          sha: '5f834de43d24c20ae761f8b4a6fd8a980928b96b',
          payload: {
            environment: 'production'
          } }
      end

      let(:output) do
        { fallback: 'Deployed shipr-test/test-repo@5f834d to production: http://shipr.test/deploys/1',
          color: '#0f0',
          fields: [
            { value: 'Deployed shipr-test/test-repo@5f834d to production: http://shipr.test/deploys/1' }
          ] }
      end

      it 'sends the proper payload' do
        notifier.notify
      end
    end

    context 'when the deployment is errored' do
      let(:input) do
        { state: 'error',
          target_url: 'http://shipr.test/deploys/1',
          name: 'shipr-test/test-repo',
          sha: '5f834de43d24c20ae761f8b4a6fd8a980928b96b',
          payload: {
            environment: 'production'
          } }
      end

      let(:output) do
        { fallback: 'Failed to deploy shipr-test/test-repo@5f834d to production: http://shipr.test/deploys/1',
          color: '#f00',
          fields: [
            { value: 'Failed to deploy shipr-test/test-repo@5f834d to production: http://shipr.test/deploys/1' }
          ] }
      end

      it 'sends the proper payload' do
        notifier.notify
      end
    end

    context 'when the deployment is failed' do
      let(:input) do
        { state: 'error',
          target_url: 'http://shipr.test/deploys/1',
          name: 'shipr-test/test-repo',
          sha: '5f834de43d24c20ae761f8b4a6fd8a980928b96b',
          payload: {
            environment: 'production'
          } }
      end

      let(:output) do
        { fallback: 'Failed to deploy shipr-test/test-repo@5f834d to production: http://shipr.test/deploys/1',
          color: '#f00',
          fields: [
            { value: 'Failed to deploy shipr-test/test-repo@5f834d to production: http://shipr.test/deploys/1' }
          ] }
      end

      it 'sends the proper payload' do
        notifier.notify
      end
    end
  end
end
