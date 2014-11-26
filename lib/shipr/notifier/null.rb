module Shipr::Notifier
  class Null < Base
    def notify(payload)
      payloads << payload
    end

    def reset
      @payloads = nil
    end

    def payloads
      @payloads ||= []
    end
  end
end
