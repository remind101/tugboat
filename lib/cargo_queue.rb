# Public: A queue that will continue enqueueing items up to a certain limit,
# then process the items in bulk.
#
# Examples
#
#   queue = CargoQueue.new(limit: 2)
#
#   queue.enqueue 1
#   queue.size
#   # => 1
#   queue.dequeue
#   # => nil
#   queue.size
#   # => 1
#
#   queue.enqueue 2
#   queue.size
#   # => 2
#   queue.dequeue
#   # => [1, 2]
#   queue.size
#   # => 1
class CargoQueue
  DEFAULTS = {
    limit: 1000
  }

  def initialize(options = {})
    @options = DEFAULTS.merge(options)
    @store = Array.new
  end

  # Public: Enqueue a new element.
  #
  # object - The element to add to the queue.
  #
  # Returns self.
  def enqueue(object)
    store.unshift(object)
    self
  end

  # Public: If the queue contains more items than `limit`, it will pop off
  # `limit` number of items.
  #
  # Returns Array if `limit` is reached.
  # Returns nil if `limit` is not reached.
  def dequeue
    store.pop(limit) if limit_reached?
  end

  # Public: The size of the queue.
  #
  # Returns Integer.
  def size
    store.size
  end

  # Public: Drain all items from the queue.
  #
  # Returns Array.
  def drain
    store.pop(store.size)
  end

private

  attr_reader :store, :options

  def limit_reached?
    size >= limit
  end

  def limit
    options[:limit]
  end
end
