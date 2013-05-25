worker_processes Integer( ENV['UNICORNS'] || 4 )
timeout 30
preload_app true
