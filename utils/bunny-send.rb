#!/usr/bin/env ruby

require 'bundler'
Bundler.require

connection = Bunny.new
connection.start

channel = connection.create_channel
exchange = channel.fanout('default')

message = ARGV.empty? ? 'Hello World!' : ARGV.join(' ')

exchange.publish(message)
puts " [x] Sent #{message}"
