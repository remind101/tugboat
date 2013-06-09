module Shipr::Queues
  class Base
    delegate :messages, to: :'Shipr'

    class << self
      # Factory method process the queue. Blocking call, since it will loop
      # forever.
      #
      # Examples
      #
      #   Queue.run
      #
      # Never returns.
      def run
        new.run
      end

      # Public: Set the name of the queue.
      #
      # queue - String name of the queue
      #
      # Examples
      #
      #   class Update < Base
      #     queue 'update'
      #   end
      #
      # Returns the name of the queue.
      def queue(queue = nil)
        @queue = queue if queue
        @queue
      end
    end

    # Public: Process each message off of the queue. Blocking call since it
    # will loop forever.
    #
    # Examples
    #
    #   queue.run
    #
    # Never returns.
    def run
      queue.poll do |message|
        process Hashie::Mash.new(JSON.parse(message.body))
      end
    end

  private

    # Internal: Called by .run to process the message.
    #
    # message - JSON decoded message body.
    #
    # Returns nothing.
    def process(message)
      processor.new(message).process
    end

    def queue
      messages.queue(self.class.queue)
    end

  end
end
