load 'git_commit_sha.rb'
require 'lib/helpers'

def handler(event:, context:)
  puts "git sha is: #{$my_git_commit_sha}"
  syn_logger "running at #{Time.now}"
end
