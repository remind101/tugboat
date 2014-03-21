module BackendSteps
  def fixture(name)
    JSON.parse File.read(File.expand_path("../../fixtures/#{name}.json", __FILE__))
  end
end

World(BackendSteps)

When(/^a ping event is received$/) do
  header 'X-Github-Event', 'ping'
  basic_authorize '', Shipr.configuration.auth_token
  post '/_github', fixture(:ping_event)
end

When(/^a deployment event is received$/) do
  header 'X-Github-Event', 'deployment'
  basic_authorize '', Shipr.configuration.auth_token
  post '/_github', fixture(:deployment_event)
end

Then(/^the last response should be (\d+) with the content:$/) do |status, body|
  expect(last_response.status).to eq status.to_i
  expect(last_response.body).to eq body
end

Then(/^a job should have been created with:$/) do |table|
  fields = table.rows_hash

  job = Shipr::Job.last
  expect(job.sha).to eq fields['sha'] if fields['sha']
  expect(job.force).to eq eval(fields['force']) if fields['force']
  expect(job.environment).to eq fields['environment'] if fields['environment']
  expect(job.config).to eq JSON.parse(fields['config']) if fields['config']
end
