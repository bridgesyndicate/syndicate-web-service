#!/usr/bin/env ruby

require 'bundler'
Bundler.require

connection = Bunny.new(automatically_recover: false)
connection.start

channel = connection.create_channel
player = '65188b65-76e3-4079-8c28-02ea07c91448'
queue = channel.queue(player)

begin
  puts ' [*] Waiting for messages. To exit press CTRL+C'
  # block: true is only used to keep the main thread
  # alive. Please avoid using it in real world applications.
  queue.subscribe(block: true) do |_delivery_info, _properties, body|
    puts " [x] Received #{body} for #{_delivery_info.routing_key}"
  end
rescue Interrupt => _
  connection.close

  exit(0)
end

