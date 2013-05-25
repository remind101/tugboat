class Job

  # ==============
  # = Delegation =
  # ==============

  delegate :iron_worker, to: Deployer
  delegate :tasks,       to: :iron_worker

  # =============
  # = Callbacks =
  # =============

  after_create :deploy

  # ===========
  # = Methods =
  # ===========

  def deploy
    tasks.create('Deploy', attributes)
  end

end
