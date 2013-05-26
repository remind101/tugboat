require 'open3'
require 'json'
require 'iron_mq'

client = IronMQ::Client.new params['iron_mq']['credentials']
queue  = client.queue 'update'

Open3.popen2e(params['env'], 'deploy') do |stdin, output, wait_thr|
  output.each do |line|
    puts line
    queue.post({ uuid: params['uuid'], output: line }.to_json)
  end
  exit_status = wait_thr.value
  queue.post({ uuid: params['uuid'], status: exit_status.to_i }.to_json)
end
