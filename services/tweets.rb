require 'twitter'
require 'rainbow/refinement'
require 'date'

using Rainbow

module Services
  class IncorrectDatesError < StandardError
    def initialize(since_valid:, until_valid:)
      @since_valid = since_valid
      @until_valid = until_valid
    end

    def to_s
      return '' if @since_valid && @until_valid
      error = ""
      error += "--since has wrong format\n" if !@since_valid
      error += "--until has wrong format\n" if !@until_valid
      error.bold.red
    end
  end

  class Tweet
    def initialize(tweet)
      @tweet = tweet
    end

    def to_s
      return '' unless valid?
      result = ''
      result += "#{tweet.created_at}\n"
      result += "#{tweet.text}\n\n"
      urls.each do |url|
        result += '> '.bold.orange
        result += "   #{url.expanded_url.to_s.bold}\n"
      end
      result += "\n\n"
    end

  private
    attr_accessor :tweet

    def urls
      @urls ||= tweet.urls.select do |url|
        !url.expanded_url.to_s.include?("https://twitter.com/")
      end
    end

    def valid?
      urls.any?
    end
  end

  class FriendUrls
    def initialize(screen_name, tweets)
      @screen_name = screen_name
      @tweets = tweets
    end

    def to_s
      screen_name.green.bold + "\n" +
      tweets.map do |tweet|
        Tweet.new(tweet).to_s
      end.select {|tweet| !tweet.empty? }.join("\n")
    end

  private
    attr_reader :screen_name, :tweets

  end

  class Tweets
    attr_reader :filter_since, :filter_until, :consumer_key, :consumer_secret, :access_token, :access_token_secret

    VALID_DATE_REGEXP = /\A\d{4}-\d{2}-\d{2}\z/

    def initialize(filter_since: nil, filter_until: nil, consumer_key: nil, consumer_secret: nil, access_token: nil, access_token_secret: nil)
      @filter_since = filter_since
      @filter_until = filter_until
      @consumer_key = consumer_key
      @consumer_secret = consumer_secret
      @access_token = access_token
      @access_token_secret = access_token_secret
      validate_dates
    end

    def self.get(opts)
      self.new(opts).get
    end

    def get
      friends_screen_names.map do |screen_name|
        FriendUrls.new(screen_name, friend_tweets(screen_name))
      end
    end

    def validate_dates
      since_valid = !invalid_date?(filter_since)
      until_valid = !invalid_date?(filter_until)
      raise IncorrectDatesError.new(since_valid: since_valid, until_valid: until_valid) unless since_valid && until_valid
    end
    
    def invalid_date?(date)
      !date.nil? && (!VALID_DATE_REGEXP.match(date) || !Date.parse(date))
    rescue ArgumentError
      return true
    end

  private

    def friends
      @friends ||= client.friends
    end

    def friend_tweets(screen_name)
      client.search('', from: screen_name, since: filter_since, until: filter_until)
    end

    def friends_screen_names
      friends.map(&:screen_name)
    end

    def client
      @client ||= ::Twitter::REST::Client.new do |config|
        config.consumer_key        = consumer_key || 'dummy_one_so_vcr_wont_panic'
        config.consumer_secret     = consumer_secret || 'dummy_one_so_vcr_wont_panic'
        config.access_token        = access_token || 'dummy_one_so_vcr_wont_panic'
        config.access_token_secret = access_token_secret || 'dummy_one_so_vcr_wont_panic'
      end
    end
  end
end
