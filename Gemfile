source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'json-schema'
gem 'aws-sdk-sqs'
gem 'aws-sdk-dynamodb'

group :test do
  gem 'rspec'
  gem 'rspec_junit_formatter'
  gem 'webmock'
end

group :development do
  gem 'pry-byebug'
  gem 'sinatra'
  gem 'rake'
end
