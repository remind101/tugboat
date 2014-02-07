When(/^I deploy the following:$/) do |table|
  fields = table.rows_hash

  post '/api/deploys', fields
end
