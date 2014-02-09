require 'open3'
require 'json'
require 'time'
require 'bunny'

conn = Bunny.new(params['rabbitmq']['url'])
ch = conn.create_channel
exchange = ch.topic(params['rabbitmq']['exchange'])

Open3.popen2e(params['env'], 'deploy') do |stdin, output, wait_thr|
  output.each do |line|
    puts line
    exchange.publish({ id: params['id'], output: line, time: Time.now.utc.iso8601 }.to_json, routing_key: 'job.output')
  end
  exit_status = wait_thr.value
  exchange.publish({ id: params['id'], exit_status: exit_status.to_i, time: Time.now.utc.iso8601 }.to_json, routing_key: 'job.complete')
end
