module Shipr
  class Hooks < Grape::API
    params do
      optional :output, type: String
      optional :exit_status, type: Integer
    end
    post do
      job = Job.find params.id

      job.append_output!(params.output) if params.output
      job.complete!(params.exit_status) if params.exit_status

      status 200

      { }
    end
  end
end
