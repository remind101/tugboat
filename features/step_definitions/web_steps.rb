When(/^I view the deploy$/) do
  response = JSON.parse(last_response.body)
  id = response['id']

  visit "/deploys/#{id}"
end

Then(/^the repo should eventually be deployed$/) do
  Capybara.using_wait_time(300) do
    expect(page).to have_content "Deployed repo"
  end
end
