class MockIronWorkerClient
  class Tasks < Array
    def create(*args)
      self << args
    end
  end

  def tasks
    @tasks ||= Tasks.new
  end
end

Shipr.workers = MockIronWorkerClient.new

Before do
  Shipr.workers.tasks.clear
end
