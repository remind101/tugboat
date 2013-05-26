worker_processes Integer( ENV['UNICORNS'] || 3 )
timeout 30
preload_app true
