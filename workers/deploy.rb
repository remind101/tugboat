require 'open3'
require 'json'
require 'iron_mq'

client = IronMQ::Client.new \
  token: params['env']['IRON_MQ_TOKEN'],
  project_id: params['env']['IRON_MQ_PROJECT_ID']

queue = client.queue('progress')

Open3.popen2e(params['env'], 'deploy') do |stdin, output, wait_thr|
  output.each do |line|
    puts line
    queue.post({ uuid: params['uuid'], output: line }.to_json)
  end
  exit_status = wait_thr.value
end
