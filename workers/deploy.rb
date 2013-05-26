require 'open3'
require 'json'
require 'iron_mq'

client   = IronMQ::Client.new params['iron_mq']['credentials']
progress = client.queue 'progress'
status   = client.queue 'status'

Open3.popen2e(params['env'], 'deploy') do |stdin, output, wait_thr|
  output.each do |line|
    puts line
    progress.post({ uuid: params['uuid'], output: line }.to_json)
  end
  exit_status = wait_thr.value
  status.post({ uuid: params['uuid'], status: exit_status }.to_json)
end
