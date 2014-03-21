module Shipr
  module Entities
    class Repo < Grape::Entity
      expose :name
      expose :clone_url
    end
  end
end
