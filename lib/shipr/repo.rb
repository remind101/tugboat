module Shipr
  class Repo
    include Mongoid::Document
    include Grape::Entity::DSL
    store_in collection: 'repos'

    has_many :jobs

    field :name, type: String

    # Public: The url to clone the repo.
    #
    # Returns String.
    def clone_url
      "git@github.com:#{name}"
    end
  end
end
