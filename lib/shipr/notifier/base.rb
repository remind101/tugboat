module Shipr::Notifier
  class Base
    def notify(payload)
      raise NotImplementedError
    end
  end
end
