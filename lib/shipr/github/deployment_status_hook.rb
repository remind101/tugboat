module Shipr
  module GitHub
    class DeploymentStatusHook < Hook
      def events
        [:deployment_status]
      end

      def url
        Shipr.configuration.notifier_url
      end
    end
  end
end
