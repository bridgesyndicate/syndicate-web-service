require 'aws-sdk-ec2'

class Ec2Manager
  attr_accessor :client

  def initialize()

    @client = Aws::EC2::Client.new(region: AwsCredentials.instance.region,
                                   credentials: AwsCredentials.instance.credentials
                                   )
  end

  def get_ip_for_iface(eni)
    resp = client.describe_network_interfaces({ network_interface_ids: [ eni ] })
    resp.to_h[:network_interfaces][0][:association][:public_ip]
  end
end

$ec2_client = Ec2Manager.new
