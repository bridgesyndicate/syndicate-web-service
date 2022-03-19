require 'aws-sdk-ecs'
require 'lib/aws_credentials'

class ECSClient

  CLUSTER = 'SyndicateECSCluster'
  REGION = 'us-east-2'
  SERVICE = 'SyndicateBridgeECSService'

  attr_accessor :client

  def self.client
    @@client ||= Aws::ECS::Client.new(region: REGION,
                                      credentials: AwsCredentials.instance.credentials
                                      )
  end

  def self.get_desired_count_for_bridge_service
    client.describe_services({
                               cluster: CLUSTER,
                               services: [SERVICE]
                             })
      .services
      .first
      .desired_count
  end
end
