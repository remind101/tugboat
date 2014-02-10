require 'open3'
require 'json'
require 'time'
require 'bunny'

class Deploy
  attr_reader :options

  def initialize(options)
    @options = options

    conn = Bunny.new(options['rabbitmq']['url'])
    conn.start
    ch = conn.create_channel
    @exchange = ch.topic(options['rabbitmq']['exchange'], durable: true)
  end

  def run
    Open3.popen2e(options['env'], 'deploy') do |stdin, output, wait_thr|
      output.each do |line|
        puts line
        publish('worker.output', output: line)
      end
      exit_status = wait_thr.value
      publish('worker.complete', exit_status: exit_status.to_i)
    end
  end

private
  attr_reader :exchange

  def publish(routing_key, message)
    message = { id: options['id'], time: Time.now.utc.iso8601 }.merge(message)
    exchange.publish(message.to_json, routing_key: routing_key, content_type: 'application/json')
  end
end

Deploy.new(params).run
