module Shipr::Notifier
  class Slack < Base
    MESSAGES = {
      pending: ['#ff0', "%s is <%s|deploying> %s@%s to %s"],
      success: ['#0f0', "%s <%s|deployed> %s@%s to %s"],
      failure: ['#f00', "Failed to deploy %s@%s to %s by %s: <%s>"],
      error:   ['#f00', "Failed to deploy %s@%s to %s by %s: <%s>"]
    }

    attr_reader :account, :token

    def initialize(account, token)
      @account = account
      @token = token
    end

    def notify(payload)
      color, message = message(payload)

      HTTParty.post "https://#{account}.slack.com/services/hooks/incoming-webhook?token=#{token}",
        body: "payload=#{JSON.dump(attachments: [{ color: color, fallback: message, text: message }])}"
    end

    private

    def message(payload)
      {
        pending: ['#ff0', "#{payload.user} is <#{payload.target_url}|deploying> #{payload.name}@#{payload.short_sha} to #{payload.environment}"],
        success: ['#0f0', "#{payload.user} <#{payload.target_url}|deployed> #{payload.name}@#{payload.short_sha} to #{payload.environment}"],
        failure: ['#f00', "#{payload.user} failed to <#{payload.target_url}|deploy> #{payload.name}@#{payload.short_sha} to #{payload.environment}"]
      }[payload.state]
    end
  end
end
