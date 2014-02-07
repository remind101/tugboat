When(/^I tail the log output$/) do
  response = JSON.parse(last_response.body)
  id = response['id']

  visit "/deploys/#{id}"
end

Then(/^I should see "(.*?)"$/) do |content|
  expect(page).to have_content content
end

When(/^I sleep$/) do
  sleep 50
end
