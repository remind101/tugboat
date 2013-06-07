module Shipr
  class Web < Sinatra::Base
    configure :test do
      set :show_exceptions, false
      set :raise_errors, true
    end
    
    set :github_options, { }
    register Sinatra::Auth::Github

    before do
      github_organization_authenticate!(ENV['GITHUB_ORGANIZATION'])
    end

    get '/' do
      'ok'
    end

    get '/:id/stream', provides: 'text/event-stream' do |id|
      job = Job.find(id)
      stream do |out|
        job.on_output do |line|
          out << "event: output\ndata: #{line}\n\n"
        end
        loop { sleep 1 }
      end
    end
  end
end
