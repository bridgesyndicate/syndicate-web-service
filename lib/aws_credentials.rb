require 'singleton'

class AwsCredentials
  include Singleton

  attr_accessor :endpoint, :credentials, :region

  def initialize
    if SYNDICATE_ENV == 'development'
      @endpoint = 'http://localhost:8000'
    end
    id = ENV['AWS_ACCESS_KEY_ID'] || 'access'
    secret = ENV['AWS_SECRET_ACCESS_KEY'] || 'secret'
    token = ENV['AWS_SESSION_TOKEN'] if SYNDICATE_ENV == 'production'
    @region = ENV['AWS_REGION'] || 'us-east-1'
    @credentials = Aws::Credentials.new(id, secret, token)
  end
end

