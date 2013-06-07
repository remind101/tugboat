module Shipr
  class Hooks < Sinatra::Base
    post '/' do
      job = Job.find params['uuid']

      if output = params['output']
        job.output << output
        job.save
      elsif status = params['status']
        job.complete(status)
      end

      'Ok'
    end
  end
end
