module Shipr
  module Entities
    class Job < Grape::Entity
      expose :id
      expose :sha
      expose :force
      expose :environment
      expose :config
      expose :exit_status
      expose :done?, as: :done
      expose :success?, as: :success
      expose :output, if: :include_output
      expose :repo, using: Repo
    end
  end
end
