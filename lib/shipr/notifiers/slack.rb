module Shipr
  module Notifiers
    class Slack < Base
      MESSAGES = {
        pending: ['#ff0', "%s is <%s|deploying> %s@%s to %s"],
        success: ['#0f0', "%s <%s|deployed> %s@%s to %s"],
        failure: ['#f00', "Failed to deploy %s@%s to %s by %s: <%s>"],
        error:   ['#f00', "Failed to deploy %s@%s to %s by %s: <%s>"]
      }

      def notify
        HTTParty.post "https://#{account}.slack.com/services/hooks/incoming-webhook?token=#{token}",
          body: "payload=#{JSON.dump(attachments: [attachment])}"
      end

    private

      def attachment
        color, message = messages[state.to_sym]
        { color: color, fallback: message, text: message }
      end

      def messages
        {
          pending: ['#ff0', "#{user} is <#{target_url}|deploying> #{name}@#{short_sha} to #{environment}"],
          success: ['#0f0', "#{user} <#{target_url}|deployed> #{name}@#{short_sha} to #{environment}"],
          failure: ['#f00', "#{user} failed to <#{target_url}|deploy> #{name}@#{short_sha} to #{environment}"]
        }
      end

      def account
        ENV['SLACK_ACCOUNT']
      end

      def token
        ENV['SLACK_TOKEN']
      end
    end
  end
end
