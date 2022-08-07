require 'aws-sdk-ecs'
require 'lib/aws_credentials'

class ECSClient

  CLUSTER = 'SyndicateECSCluster'
  FAMILY = 'SyndicateBridgeTaskDefinition'

  attr_accessor :tasks_subnet, :tasks_security_group

  def initialize(tasks_subnet: nil,
                 tasks_security_group: nil)
    @tasks_subnet = tasks_subnet
    @tasks_security_group = tasks_security_group
  end

  def client
    @client ||= Aws::ECS::Client.new(
      credentials: AwsCredentials.instance.credentials
    )
  end

  def list_tasks
    client.list_tasks({
                        cluster: CLUSTER,
                        family: FAMILY,
                      })
  end

  def run_task
    client.run_task({
                      enable_execute_command: true,
                      cluster: CLUSTER,
                      network_configuration: {
                        awsvpc_configuration: {
                          subnets: Array.new.push(tasks_subnet),
                          security_groups: Array.new.push(tasks_security_group),
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

  def stop_task(task_arn)
    client.stop_task({
                       task: task_arn,
                       cluster: CLUSTER
                     })
  end
end
