require 'approvals/rspec'

Approvals.configure do |c|
  c.excluded_json_keys = {
    id: /(\A|_)id$/
  }
end
