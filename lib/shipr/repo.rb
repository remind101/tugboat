module Shipr
  class Repo
    GIT = 'git@github.com:%s.git'.freeze

    include Mongoid::Document
    include Grape::Entity::DSL
    store_in collection: 'repos'

    has_many :jobs

    field :name, type: String

    # Public: The url to clone the repo.
    #
    # Returns String.
    def clone_url
      GIT % name
    end
  end
end
