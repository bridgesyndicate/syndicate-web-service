load 'spec_helper.rb'
require 'helpers'
require 'appconfig_client'

RSpec.describe '#appconfig_client.rb' do
  before(:each) do
    stub_request(:get, 'https://appconfig.us-east-1.amazonaws.com/applications/SyndicateGameContainerAutoScale/environments/production/configurations/GameContainerAutoScaling?client_id=Lambda')
      .to_return(status: 200, body: File.read('spec/mocks/web-mock-appconfig-get-configuration/success.json'))
  end

  describe 'for getting ContainerMetadataDelay' do
    it 'gets a client' do
      expect(AppconfigClient.client).to be_a Aws::AppConfig::Client
    end
    it 'gets a configuration' do
      expect(AppconfigClient.get_configuration).to be_a Hash
      expect(AppconfigClient.get_configuration[:min_tasks])
        .to be_a Integer
      expect(AppconfigClient.get_configuration[:max_task_start_delay_seconds])
        .to be_a Integer
    end
  end
end
