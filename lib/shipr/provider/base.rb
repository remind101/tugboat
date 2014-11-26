module Shipr::Provider
  class Base
    def start(job)
      raise NotImplementedError
    end
  end
end
