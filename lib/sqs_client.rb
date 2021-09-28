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
    env_and_name = "#{SYNDICATE_ENV}_#{queue_name}"
    case env_and_name
    when "development_#{GAME}"
      'https://sqs.us-west-2.amazonaws.com/595508394202/syndicate_development_games'
    when "production_#{GAME}"
      'https://sqs.us-west-2.amazonaws.com/595508394202/syndicate_production_games'
    when /production_#{DELAYED_WARPS}/
      'https://sqs.us-west-2.amazonaws.com/595508394202/syndicate_production_delayed_warps'
    end
  end

  def enqueue(queue_name, message)
    @client.send_message({
                           queue_url: get_queue_url(queue_name),
                           message_body: message
                         })
  end

  def enqueue_with_delay(queue_name, delay, message)
    @client.send_message({
                           queue_url: get_queue_url(queue_name),
                           delay_seconds: delay,
                           message_body: message
                         })
  end
end


$sqs_manager     = SqsManager.new()
