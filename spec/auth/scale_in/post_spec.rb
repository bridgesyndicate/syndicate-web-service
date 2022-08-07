load 'spec_helper.rb'
require 'lambda/auth/scale_in/post'
require 'json-schema'
require 'lib/schema/scale_in'
require 'lib/helpers'

RSpec.describe '#scale_in' do
  context 'lambda_result' do
    let(:post_body) {
      {
        task_arn: 'foo'
      }
    }
    let(:event) { { 'body' =>  JSON.generate(post_body) } }
    let(:lambda_result) { auth_scale_in_post_handler(event: event, context: '') }

    before(:each) do
      stub_request(:post, 'https://ecs.us-east-1.amazonaws.com/')
        .to_return(status: 200,
                   body: File.read('spec/mocks/web-mock-ecs-list-tasks/one-task.json')
                   )
      stub_request(:post, "https://monitoring.us-east-1.amazonaws.com/")
        .to_return(status: 200,
                   body: File.read('spec/mocks/web-mock-cloudwatch-get_metric_statistics/ContainerMetadataDelay-five-minute-maximum.xml')
                   )
      stub_request(:get, 'https://appconfig.us-east-1.amazonaws.com/applications/SyndicateGameContainerAutoScale/environments/production/configurations/GameContainerAutoScaling?client_id=Lambda')
        .to_return(status: 200, body: File.read('spec/mocks/web-mock-appconfig-get-configuration/success.json'))
    end

    describe 'for the post response' do
      it_behaves_like 'lambda function'
    end

    describe 'for invalid posts' do
      describe 'with missing properties' do
        let(:post_body) {
          {
            foo: 'bar'
          }
        }
        it 'does not lint' do
          expect(lambda_result[:statusCode]).to eq 400
        end
        it 'returns an empty body' do
          expect( JSON.parse(lambda_result[:body])['reason'] ).to eq 'Payload json does not validate against schema.'
        end
      end
      describe 'with extra properties' do
        let(:post_body) {
          {
            task_arn: 'arn:aws:ecs:us-east-1:595508394202:task/SyndicateECSCluster/250d85bc107e4dcbb39666340c2a3d1e',
            foo: 'bar'
          }
        }
        it 'does not lint' do
          expect(lambda_result[:statusCode]).to eq 400
        end
      end
      describe 'with invalid json' do
        let(:post_body) { '{foobarbaz,,,' }
        it 'does not lint' do
          expect(lambda_result[:statusCode]).to eq 400
        end
      end
    end
  end
end
