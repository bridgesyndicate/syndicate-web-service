require 'aws-sdk-cloudwatch'
require 'lib/aws_credentials'

class CloudwatchClient

  METRIC_NAME = 'ContainerMetadataDelay'

  def self.client
    @@client ||= Aws::CloudWatch::Client.new(region: AwsCredentials.instance.region,
                                        credentials: AwsCredentials.instance.credentials
                                        )
  end

  def self.get_container_metadata_delay
    right_now = Time.now
    five_minutes_ago = right_now - 300
    client.get_metric_statistics({
                                   namespace: "syndicate_production",
                                   metric_name: METRIC_NAME,
                                   start_time: five_minutes_ago.utc.iso8601,
                                   end_time: right_now.utc.iso8601,
                                   period: 300,
                                   statistics: %w/Average/
                                 }).datapoints.first.average
  end

  def self.put_queue_delay_data(seconds)
    client.put_metric_data({
                               namespace: "syndicate_#{SYNDICATE_ENV}",
                               metric_data: [
                                 {
                                   metric_name: 'ContainerMetadataDelay',
                                   timestamp: Time.now,
                                   value: seconds,
                                   unit: 'Seconds'
                                 }
                               ]
                             }
                            )
  end

  def self.put_game_container_task_count(count)
    client.put_metric_data({
                               namespace: "syndicate_#{SYNDICATE_ENV}",
                               metric_data: [
                                 {
                                   metric_name: 'GameContainerTaskCount',
                                   timestamp: Time.now,
                                   value: count,
                                   unit: 'Count'
                                 }
                               ]
                             }
                            )
  end
end
