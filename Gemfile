source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'aws-sdk-dynamodb'
gem 'aws-sdk-dynamodbstreams'
gem 'aws-sdk-sqs'
gem 'bunny'
gem 'elo_rating'
gem 'json-schema'
gem 'oj'
gem 'pg', '~> 0.18.4'
gem 'pry-byebug'

group :test do
  # gem 'pg_tester', wants ancient pg 0.18
  gem 'simplecov', require: false, group: :test
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'timecop'
  gem 'webmock'
end

group :development do
  gem 'rake'
  gem 'sinatra'
end
