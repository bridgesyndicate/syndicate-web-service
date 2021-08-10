require 'aws-sdk-sqs'

class SqsManager
  attr_accessor :client

  def initialize()

    @client = Aws::SQS::Client.new(region: AwsCredentials.instance.region,
                                        credentials: AwsCredentials.instance.credentials
                                        )
  end

  def create_queue(queue_name)
    create_queue_impl(queue_name) unless @client.list_queues.queue_names.include?(queue_name)
  end

  def create_queue_impl(queue_name)
    return @client.create_queue({
                                  queue_name: queue_name
                                })
  end

  def get_queue_url(queue_name)
    return 'https://sqs.us-west-2.amazonaws.com/595508394202/syndicate_production_games' if queue_name.match /^GAME/
  end

  # queue_name_resp = client.get_queue_url({ queue_name: @queue_name }) # want to avoid another service call

  def enqueue(queue_name, message)
    @client.send_message({
                           queue_url: get_queue_url(queue_name),
                           message_body: message
                         })
  end
end
