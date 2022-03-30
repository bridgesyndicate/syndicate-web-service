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
    res = container_metadata_delay
    res.datapoints.first ? res.datapoints.first.average : 0
  end

  def self.container_metadata_delay
    right_now = Time.now
    fifteen_minutes_in_seconds = 60 * 15
    fifteen_minutes_ago = right_now - fifteen_minutes_in_seconds
    client.get_metric_statistics({
                                   namespace: "syndicate_production",
                                   metric_name: METRIC_NAME,
                                   start_time: fifteen_minutes_ago.utc.iso8601,
                                   end_time: right_now.utc.iso8601,
                                   period: fifteen_minutes_in_seconds,
                                   statistics: %w/Maximum/
                                 })
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
