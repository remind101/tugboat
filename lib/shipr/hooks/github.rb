module Shipr::Hooks
  # Internal: An endpoint for processing GitHub post receive hooks and creating
  # a deploy.
  class GitHub < Grape::API
    logger Shipr.logger

    helpers Helpers

    helpers do
      delegate :payload, to: :params
    end

    params do
      requires :payload, type: Hash
    end
    post do
      deploy(repo: payload.repository.url, ref: payload.ref)
    end
  end
end
