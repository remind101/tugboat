require 'sinatra/base'

module Shipr
  class Web < Sinatra::Base
    set :root, File.join(File.dirname(__FILE__), 'web')
    set :github_options, { }
    register Sinatra::Auth::Github

    configure :test do
      set :show_exceptions, false
      set :raise_errors, true
    end

    helpers do
      def stream_url(job)
        "#{request.scheme}://#{request.host_with_port}/deploys/#{job.id}/stream"
      end
    end

    before do
      github_organization_authenticate!(ENV['GITHUB_ORGANIZATION'])
    end

    get '/' do
      'ok'
    end

    get '/deploys/:id' do |id|
      @job = Job.find(id)
      haml :job
    end

    get '/deploys/:id/stream', provides: 'text/event-stream' do |id|
      job = Job.find(id)
      stream :keep_open do |out|

        # The Heroku router needs to see some kind of response every 30 seconds
        # or it will close the connection.
        Thread.new do
          EM.run { EM::PeriodicTimer.new(15) { out << "\0" } }
        end

        job.on_output do |line|
          line = { line: line }.to_json
          out << "event: output\ndata: #{line}\n\n"
        end
        loop { sleep 1 }
      end
    end
  end
end
