require 'aws-sdk-ecs'
require 'lib/aws_credentials'

class ECSClient

  CLUSTER = 'SyndicateECSCluster'
  REGION = 'us-east-2'
  FAMILY = 'SyndicateBridgeTaskDefinition'

  attr_accessor :client

  def self.client
    @@client ||= Aws::ECS::Client.new(region: REGION,
                                      credentials: AwsCredentials.instance.credentials
                                      )
  end

  def self.list_tasks
    client.list_tasks({
                        cluster: CLUSTER,
                        family: FAMILY,
                      })
  end

  def self.run_task
    client.run_task({
                      enable_execute_command: true,
                      cluster: CLUSTER,
                      network_configuration: {
                        awsvpc_configuration: {
                          subnets: ["subnet-02fb1f76eb1218cdf"],
                          security_groups: ["sg-0a3438c7a37460f7e"],
                          assign_public_ip: "DISABLED"
                        },
                      },
                      task_definition: "SyndicateBridgeTaskDefinition"
                    })
      .tasks
      .first
      .containers
      .first
      .task_arn
  end
end
