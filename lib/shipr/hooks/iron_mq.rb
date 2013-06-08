module Shipr::Hooks
  # Internal: Receives hooks from Iron.io
  #
  # TODO: Authenticate this.
  class IronMQ < Grape::API
    # We don't want Iron.io to keep ping us, so send it back a 200 response.
    rescue_from ActiveRecord::RecordNotFound do |e|
      Rack::Response.new('', 200)
    end

    params do
      optional :output, type: String
      optional :exit_status, type: Integer
    end
    post do
      job = Job.find params.id

      job.append_output!(params.output) if params.output?
      job.complete!(params.exit_status) if params.exit_status?

      status 200

      { }
    end
  end
end
