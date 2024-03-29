#!/usr/bin/env ruby
require 'bundler'
Bundler.require
require 'bunny'

connection = Bunny.new
connection.start

channel = connection.create_channel
exchange = channel.fanout('default')
queue = channel.queue('', exclusive: true)

queue.bind(exchange)

puts ' [*] Waiting for logs. To exit press CTRL+C'

begin
  # block: true is only used to keep the main thread
  # alive. Please avoid using it in real world applications.
  queue.subscribe(block: true) do |_delivery_info, _properties, body|
    puts " [x] #{body}"
  end
rescue Interrupt => _
  channel.close
  connection.close
end
