source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'aws-sdk-appconfig'
gem 'aws-sdk-cloudwatch'
gem 'aws-sdk-dynamodb'
gem 'aws-sdk-dynamodbstreams'
gem 'aws-sdk-ecs'
gem 'aws-sdk-sqs'
gem 'bunny'
gem 'elo_rating'
gem 'faraday'
gem 'json-schema'
gem 'pg', '~> 0.18.4'
gem 'pry-byebug'
gem 'ruby-uuid'

group :test do
  gem 'simplecov', require: false, group: :test
  gem 'simplecov-cobertura'
  gem 'simplecov-json'
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'timecop'
  gem 'webmock'
  gem 'faker'
end

group :development do
  gem 'rake'
  gem 'sinatra'
end
