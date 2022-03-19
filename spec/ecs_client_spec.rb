load 'spec_helper.rb'
require 'helpers'
require 'ecs_client'

RSpec.describe '#cloudwatch_client' do
  before(:each) do
    stub_request(:post, 'https://ecs.us-east-2.amazonaws.com/')
      .to_return(status: 200,
                 body: File.read('spec/mocks/web-mock-ecs-describe_services/desired_count.json'),
                 headers: {})
  end
  
  describe 'for getting ContainerMetadataDelay' do
    it 'gets a client' do
      expect(ECSClient.client).to be_a Aws::ECS::Client
    end
    it 'gets the desired_count_for_service' do
      expect(ECSClient.get_desired_count_for_bridge_service).to eq 1
    end
  end
end
