require 'json'
require 'aws-sdk-appconfig'
require 'lib/aws_credentials'

class AppconfigClient

  def self.client
    @@client ||= Aws::AppConfig::Client.new(credentials: AwsCredentials.instance.credentials)
  end

  def self.get_configuration
    JSON.parse(client.get_configuration({
                               application: 'SyndicateGameContainerAutoScale',
                               environment: 'production',
                               configuration: 'GameContainerAutoScaling',
                               client_id: 'Lambda'
                             })
      .content
      .readlines
      .join("\n")).transform_keys(&:to_sym)
  end
end
