source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'json-schema'
gem 'aws-sdk-sqs'
gem 'aws-sdk-dynamodb'
gem 'aws-sdk-ecs'
gem 'aws-sdk-ec2'

group :test do
  gem 'simplecov', require: false, group: :test
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'webmock'
end

group :development do
  gem 'pry-byebug'
  gem 'sinatra'
  gem 'rake'
end
