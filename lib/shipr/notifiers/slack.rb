module Shipr
  module Notifiers
    class Slack < Base
      def notify
        HTTParty.post "https://#{account}.slack.com/services/hooks/incoming-webhook?token=#{token}",
          body: "payload=#{JSON.dump(text: 'Fuck it')}"
      end

    private

      def account
        ENV['SLACK_ACCOUNT']
      end

      def token
        ENV['SLACK_TOKEN']
      end
    end
  end
end
