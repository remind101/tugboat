require 'uuid'

class Job

  attr_reader :uuid

  # ==============
  # = Delegation =
  # ==============

  delegate :iron_worker, :redis, to: Deployer
  delegate :set, :get, to: :redis
  delegate :tasks, to: :iron_worker

  # ===========
  # = Methods =
  # ===========

  def self.create(*args)
    # TODO
  end

end
