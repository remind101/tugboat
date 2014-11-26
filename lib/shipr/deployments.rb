module Shipr::Deployments
  extend self

  autoload :AbstractService,     'shipr/deployments/abstract_service'
  autoload :BaseService,         'shipr/deployments/base_service'
  autoload :PushedService,       'shipr/deployments/pushed_service'
  autoload :DeployService,       'shipr/deployments/deploy_service'
  autoload :GitHubStatusService, 'shipr/deployments/github_status_service'

  def backend=(backend)
    @backend = backend
    @service = nil
  end

  def backend
    @backend ||= BaseService.new
  end

  def service
    @service ||= backend
  end
end
