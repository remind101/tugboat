When(/^I view the deploy$/) do
  response = JSON.parse(last_response.body)
  id = response['id']

  visit "/deploys/#{id}"
end

Then(/^the deploy should finish$/) do
  Capybara.using_wait_time(300) do
    expect(page).to have_content "Use '--' to separate paths from revisions"
  end
end
