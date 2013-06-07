module Shipr
  class Hooks < Sinatra::Base
    post '/' do
      job = Job.find params['uuid']

      if output = params['output']
        job.append_output(output)
      elsif status = params['status']
        job.complete(status)
      end

      'Ok'
    end
  end
end
