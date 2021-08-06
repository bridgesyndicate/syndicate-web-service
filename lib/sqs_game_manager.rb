require 'aws-sdk-sqs'

class SqsGameManager
  attr_accessor :client, :queue_name

  def initialize()

    @queue_name = "syndicate_#{SYNDICATE_ENV}_games"

    @client = Aws::SQS::Client.new(region: AwsCredentials.instance.region,
                                        credentials: AwsCredentials.instance.credentials
                                        )
  end

  def create_queue
    create_queue_impl unless @client.list_queues.queue_names.include?(@queue_name)
  end

  def create_queue_impl
    return @client.create_queue({
                                  queue_name: @queue_name
                                })
  end

  def get_queue_url(queue_name)
    lut = { syndicate_development_games: 'https://sqs.us-west-2.amazonaws.com/595508394202/syndicate_development_games',
      syndicate_production_games:  'https://sqs.us-west-2.amazonaws.com/595508394202/syndicate_production_games'}
    return lut[queue_name.to_sym]
  end

  # queue_name_resp = client.get_queue_url({ queue_name: @queue_name }) # want to avoid another service call

  def enqueue(message)
    @client.send_message({
                           queue_url: get_queue_url(@queue_name),
                           message_body: message
                         })
  end
end
