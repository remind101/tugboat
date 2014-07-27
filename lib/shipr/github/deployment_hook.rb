module Shipr
  module GitHub
    class DeploymentHook < Hook
      def events
        [:deployment]
      end

      def url
        Shipr.configuration.github_hook
      end
    end
  end
end
