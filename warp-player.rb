#!/usr/bin/env ruby

libpath = File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
$LOAD_PATH.unshift(libpath) unless $LOAD_PATH.include?(libpath)
dotpath = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(dotpath) unless $LOAD_PATH.include?(dotpath)

require 'json'
require 'ostruct'
require 'json-schema'
load 'git_commit_sha.rb'

require 'lib/aws_credentials'
require 'lib/helpers'
require 'lib/rabbit_client_factory'

rabbit_client = RabbitClientFactory.produce

id = '3bdf3018-3558-46d5-b405-a654cb40e222'
container_name = container_ip = '172.27.0.3'

puts "rabbit send_player_to_host #{id} #{container_name} #{container_ip}"
rabbit_client.send_player_to_host(id, container_name, container_ip)
