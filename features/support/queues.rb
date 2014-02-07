fork { Shipr::Queues::Update.run }.tap do |id|
  at_exit { Process.kill('KILL', id) }
end
