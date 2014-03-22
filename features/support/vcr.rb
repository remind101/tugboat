require 'webmock/cucumber'

VCR.configure do |config|
  config.register_request_matcher :body do |r1, r2|
    [r1, r2].each do |request|
      request.body.gsub! /"target_url":"(.*?)"/, '"target_url":""'
    end

    r1.body == r2.body
  end

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
