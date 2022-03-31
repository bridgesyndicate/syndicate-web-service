load 'spec_helper.rb'
require 'helpers'
require 'cloudwatch_client'

RSpec.describe '#cloudwatch_client' do
  before(:each) do
    stub_request(:post, "https://monitoring.us-east-1.amazonaws.com/")
      .to_return(status: 200,
                 body: File.read(response_body_file))
  end

  describe 'for getting ContainerMetadataDelay' do
    let(:response_body_file) { 'spec/mocks/web-mock-cloudwatch-get_metric_statistics/ContainerMetadataDelay-five-minute-maximum.xml' }
    it 'gets a client' do
      expect(CloudwatchClient.client).to be_a Aws::CloudWatch::Client
    end
    it 'ContainerMetadataDelay maximum has one datapoint' do
      expect(CloudwatchClient.get_container_metadata_delay)
        .to eq 599.140511345
    end
  end

  describe 'when ContainerMetadataDelay is empty' do
    let(:response_body_file){ 'spec/mocks/web-mock-cloudwatch-get_metric_statistics/no-datapoints.json'}
    it 'returns zero' do
      expect(CloudwatchClient.get_container_metadata_delay)
        .to eq 0
    end
  end
end
