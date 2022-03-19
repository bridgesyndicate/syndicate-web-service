load 'spec_helper.rb'
require 'helpers'
require 'cloudwatch_client'

RSpec.describe '#cloudwatch_client' do
  before(:each) do
    stub_request(:post, "https://monitoring.us-east-1.amazonaws.com/")
      .to_return(status: 200,
                 body: File.read('spec/mocks/web-mock-cloudwatch-get_metric_statistics/actual.xml'),
                 headers: {})
  end
  describe 'for getting ContainerMetadataDelay' do
    it 'gets a client' do
      expect(CloudwatchClient.client).to be_a Aws::CloudWatch::Client
    end
    it 'gets the metric data' do
      expect(CloudwatchClient.get_container_metadata_delay).to be_a Seahorse::Client::Response
    end
  end
end
