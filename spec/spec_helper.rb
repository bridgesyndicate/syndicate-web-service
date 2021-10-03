require 'simplecov'
require 'webmock/rspec'

SimpleCov.start

ENV['SYNDICATE_ENV'] = 'test'
ENV['AWS_REGION'] = 'us-west-2'

Bundler.require(:default, 'test')

root = File.expand_path("..", File.dirname(__FILE__))
$LOAD_PATH.unshift(root) unless $LOAD_PATH.include?(root)

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

# WebMock.allow_net_connect!

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
