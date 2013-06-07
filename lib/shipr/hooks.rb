module Shipr
  class Hooks < Sinatra::Base
    post '/' do
      job = Job.find params['uuid']

      if output = params['output']
        job.output << output
      elsif status = params['status']
        job.status = status
      end

      job.save

      'Ok'
    end
  end
end
