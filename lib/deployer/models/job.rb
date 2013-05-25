class Job

  # ==============
  # = Delegation =
  # ==============

  delegate :iron_worker, :redis, to: Deployer
  delegate :tasks, to: :iron_worker

  # ===========
  # = Methods =
  # ===========

  def self.create(*args)
    # TODO
  end

end
