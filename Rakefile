require 'bundler'

Bundler.require
libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)

require 'dynamodb_game_manager'
require 'helpers'

task default: %w/create_game_table/

task :create_game_table do
  options = {
    region: ENV['AWS_REGION'],
  }

  if SYNDICATE_ENV != 'production'
    options[:endpoint] = 'http://localhost:8000'
  end

  manager = DynamodbGameManager.new(**options)
  puts manager.create_table
end
  
