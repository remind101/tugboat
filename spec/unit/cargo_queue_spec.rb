require 'spec_helper'

describe CargoQueue do
  let(:queue) { described_class.new(limit: 2, max_age: 1000) }

  before do
    Timecop.freeze
  end

  describe '#enqueue' do
    it 'adds an element to the queue' do
      queue.enqueue 'foo'
      expect(queue.size).to eq 1
    end
  end

  describe '#dequeue' do
    before do
      queue.enqueue 'foo'
    end

    context 'when the element is new and the limit has not been reached' do
      it 'does nothing' do
        expect { queue.dequeue }.to_not change { queue.size }
      end
    end

    context 'when the limit has been reached' do
      before do
        queue.enqueue 'bar'
        queue.enqueue 'foobar'
      end

      it 'dequeues up to the limit everything' do
        expect { queue.dequeue }.to change { queue.size }.from(3).to(1)
      end

      it 'returns the poped elements' do
        expect(queue.dequeue).to include *%w[foo bar]
      end
    end
  end

  describe '#drain' do
    before do
      queue.enqueue 'foo'
    end

    it 'drains all items from the queue, regardless of the size' do
      expect { queue.drain }.to change { queue.size }.from(1).to(0)
    end
  end
end
