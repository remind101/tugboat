require 'open3'
require 'json'
require 'iron_mq'
require 'time'
require 'thread/pool'

client = IronMQ::Client.new params['iron_mq']['credentials']
queue  = client.queue 'update'
pool   = Thread.pool(50)

Open3.popen2e(params['env'], 'deploy') do |stdin, output, wait_thr|
  output.each do |line|
    puts line
    pool.process { queue.post({ id: params['id'], output: line, time: Time.now.utc.iso8601 }.to_json) }
  end
  exit_status = wait_thr.value
  pool.process { queue.post({ id: params['id'], exit_status: exit_status.to_i, time: Time.now.utc.iso8601 }.to_json) }
  pool.shutdown
end
