class GithubUser
  def organization_member?(*)
    true
  end
end

Given(/^I am api authenticated$/) do
  authorize '', ENV['AUTH_TOKEN']
end

When(/^I authenticate with github$/) do
  login_as GithubUser.new
end
