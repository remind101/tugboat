require 'thread/pool'

module Shipr::Queues
  class Base
    delegate :messages, to: :'Shipr'
    delegate :info, to: :'Shipr.logger'

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
        begin
          process Hashie::Mash.new(JSON.parse(message.body))
        rescue => e
          # TODO: Should probably actually handle errors, but I don't really care
          # right now.
          info e.inspect
        end
      end
    end

  private

    def queue
      @queue ||= messages.queue(self.class.queue)
    end

  end
end
