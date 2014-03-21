require 'webmock/cucumber'

VCR.configure do |config|
  config.cassette_library_dir = 'features/cassettes'
  config.default_cassette_options = {
    match_requests_on: [:method, :uri, :body],
    record: ENV['CI'] ? :none : :once,
    allow_playback_repeats: false,
    allow_unused_http_interactions: false,
    decode_compressed_response: true,
    erb: true
  }
  config.hook_into :webmock
  config.ignore_localhost = true

  config.filter_sensitive_data('<GITHUB_DEPLOY_TOKEN>') do
    ENV['GITHUB_DEPLOY_TOKEN']
  end
end

VCR.cucumber_tags do |t|
  t.tag '@vcr', use_scenario_name: true
end
