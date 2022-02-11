require 'aws-sdk-cloudwatch'

class CloudwatchClient

  def self.client
    @@client ||= Aws::CloudWatch::Client.new(region: AwsCredentials.instance.region,
                                        credentials: AwsCredentials.instance.credentials
                                        )
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
