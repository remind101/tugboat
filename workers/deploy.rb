require 'open3'
require 'json'
require 'time'
require 'bunny'

class Deploy
  RETRIES    = 3 # times
  RETRY_WAIT = 5 # seconds

  attr_reader :options

  def initialize(options)
    @options = options
    connect
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

  def connect
    retries = RETRIES

    begin
      conn = Bunny.new(options['rabbitmq']['url'])
      conn.start
      ch = conn.create_channel
      @exchange = ch.topic(options['rabbitmq']['exchange'], durable: true)
    rescue Bunny::TCPConnectionFailed
      if retries > 0
        retries -= 1
        sleep RETRY_WAIT
        retry
      end
      raise
    end
  end

  def publish(routing_key, message)
    message = { id: options['id'], time: Time.now.utc.iso8601 }.merge(message)
    exchange.publish(message.to_json, routing_key: routing_key, content_type: 'application/json')
  end
end

Deploy.new(params).run
