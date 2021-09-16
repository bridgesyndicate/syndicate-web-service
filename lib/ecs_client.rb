require 'aws-sdk-ecs'

class EcsManager
  attr_accessor :client

  def initialize()
    @client = Aws::ECS::Client.new(region: AwsCredentials.instance.region,
                                        credentials: AwsCredentials.instance.credentials
                                   )
  end

  def get_iface_for_task_arn(task_arn)
    resp = client.describe_tasks({ tasks: [task_arn] })
    if resp.failures
      'missing'
    else
      resp.to_h[:tasks][0][:attachments][0][:details].select{|e| e[:name] == 'networkInterfaceId'}[0][:value]
    end
  end
end

$ecs_client = EcsManager.new
