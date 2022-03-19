require 'aws-sdk-cloudwatch'
require 'aws_credentials'

class CloudwatchClient

  METRIC_NAME = 'ContainerMetadataDelay'

  def self.client
    @@client ||= Aws::CloudWatch::Client.new(region: AwsCredentials.instance.region,
                                        credentials: AwsCredentials.instance.credentials
                                        )
  end

  def self.get_container_metadata_delay
    client.get_metric_statistics({
                                   namespace: "syndicate_production",
                                   metric_name: METRIC_NAME,
                                   start_time: '2022-02-14T03:40:00Z',
                                   end_time: '2022-02-14T04:40:00Z',
                                   period: 300,
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
end
