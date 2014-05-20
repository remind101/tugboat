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
    let(:input) do
      { state: state,
        target_url: 'http://shipr.test/deploys/1',
        deployment: {
          sha: '5f834de43d24c20ae761f8b4a6fd8a980928b96b',
          payload: {
            environment: 'production',
            user: 'ejholmes'
          }
        },
        repository: {
          name: 'shipr-test/test-repo',
        } }
    end

    before do
      color, message = *expected
      stub_request(:post, "https://#{account}.slack.com/services/hooks/incoming-webhook?token=#{token}")
        .with(body: "payload=#{JSON.dump(attachments: [{ color: color, fallback: message, text: message }])}")
    end

    context 'when the deployment is pending' do
      let(:state   ) { 'pending' }
      let(:expected) { ['#ff0', 'ejholmes is <http://shipr.test/deploys/1|deploying> shipr-test/test-repo@5f834d to production'] }

      it 'sends the proper payload' do
        notifier.notify
      end
    end

    pending 'when the deployment is successful' do
      let(:state   ) { 'success' }
      let(:expected) { ['#0f0', 'ejholmes <http://shipr.test/deploys/1|deployed> shipr-test/test-repo@5f834d to production'] }

      it 'sends the proper payload' do
        notifier.notify
      end
    end

    pending 'when the deployment is failed' do
      let(:state   ) { 'failure' }
      let(:expected) { ['#f00', 'ejholmes failed to <http://shipr.test/deploys/1|deploy> shipr-test/test-repo@5f834d to production'] }

      it 'sends the proper payload' do
        notifier.notify
      end
    end
  end
end
