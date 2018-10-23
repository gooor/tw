require 'vcr'

VCR.configure do |config|
  config.filter_sensitive_data('<TWITTER_CONSUMER_KEY>') { ENV['TWITTER_CONSUMER_KEY'] }
  config.filter_sensitive_data('<TWITTER_CONSUMER_SECRET>') { ENV['TWITTER_CONSUMER_SECRET'] }
  config.filter_sensitive_data('<TWITTER_ACCESS_TOKEN>') { ENV['TWITTER_ACCESS_TOKEN'] }
  config.filter_sensitive_data('<TWITTER_ACCESS_TOKEN_SECRET>') { ENV['TWITTER_ACCESS_TOKEN_SECRET'] }
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
end