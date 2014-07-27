module Shipr
  module GitHub
    class DeploymentHook < Hook
      def events
        [:deployment, :deployment_status]
      end

      def url
        Shipr.configuration.github_hook
      end
    end
  end
end
