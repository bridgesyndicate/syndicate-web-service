load 'spec_helper.rb'
require 'lambda/auth/ban/delete'
require 'lambda/auth/ban/post'
require 'lib/helpers'

RSpec.describe '#ban' do
  context 'delete' do

    let(:minecraft_uuid) { '9b6efcde-8870-4c3e-9b5b-1ea9c336e2b2' }
    let(:event) {
      {
        'pathParameters' => {
          'proxy' => minecraft_uuid
        }
      }
    }
    let(:lambda_result) { auth_ban_delete_handler(event: event, context: '') }
    let(:status) { 200 }
    let(:body) { File.read('spec/mocks/ddb/web-mock-ddb-unban-success.json') }

    before(:each) do
      stub_request(:post, "http://localhost:8000/")
        .to_return(status: status,
                   body: body)
    end


    describe 'for the get response body' do
      it_behaves_like 'lambda function'
    end

    describe 'for the get response' do
      describe 'for a valid user' do
        it 'it succeeds' do
          expect(lambda_result[:statusCode]).to eq 200
        end
      end

      describe 'for an error' do
        let(:uuid) { 'abcd' }
        let(:status) { 400 }
        let(:body) { File.read('spec/mocks/ddb/web-mock-ddb-unban-failure.json') }
        it 'returns 400' do
          expect {
            lambda_result
          }.to raise_error Aws::DynamoDB::Errors::ConditionalCheckFailedException
        end
      end
    end
  end

  context 'post' do
    let(:post_body) {
      {
        task_arn: 'foo'
      }
    }
    let(:event) { { 'body' =>  JSON.generate(post_body) } }
    let(:lambda_result) { auth_ban_post_handler(event: event, context: '') }
    let(:minecraft_uuid) { '9b6efcde-8870-4c3e-9b5b-1ea9c336e2b2' }

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
      describe 'with valid json' do
        before(:each) do
          stub_request(:post, "http://localhost:8000/")
            .to_return(status: 200,
                       body: File.read('spec/mocks/ddb/web-mock-ddb-ban-success.json'),
                       headers: {})
        end
        let(:post_body) { 
          {
            minecraft_uuid: minecraft_uuid
          }
        }
        it 'succeeds' do
          expect(lambda_result[:statusCode]).to eq 200
        end
      end
    end
  end
end
