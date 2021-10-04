require 'simplecov'
require 'webmock/rspec'

SimpleCov.start

ENV['SYNDICATE_ENV'] = 'test'
ENV['AWS_REGION'] = 'us-east-1'

Bundler.require(:default, 'test')

root = File.expand_path("..", File.dirname(__FILE__))
$LOAD_PATH.unshift(root) unless $LOAD_PATH.include?(root)

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

# WebMock.allow_net_connect!

RSpec.configure do |config|
  config.before :example do |x|
    $example_name = x.metadata[:full_description]
  end
end


def webmock_log_request
  WebMock.after_request do |req, response|
    request = {
      uri: req.uri.to_s,
      method: req.method.to_s.upcase,
      headers: req.headers,
      body: req.body
    }
    puts req.inspect
    puts response.inspect
  end
end



def get_srandom_minecraft_uuids
  srand(ENV['srand'].to_i)
  (rand(4) + 1).times.map {random_uuid}
end

def get_one_srandom_minecraft_uuid
  srand(ENV['srand'].to_i)
  random_uuid
end

def random_uuid
  [Random.bytes(4).unpack("H*"),
   Random.bytes(2).unpack("H*"),
   Random.bytes(2).unpack("H*"),
   Random.bytes(2).unpack("H*"),
   Random.bytes(6).unpack("H*")].join('-')
end

def seeded_random_integer(seed)
  srand((Digest::MD5.hexdigest seed).to_i(16))
  rand(10**16)
end

def seeded_random_uuid(seed)
  srand((Digest::MD5.hexdigest seed).to_i(16))
  random_uuid
end
