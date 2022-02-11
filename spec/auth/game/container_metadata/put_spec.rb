load 'spec_helper.rb'
require 'lambda/auth/game/container_metadata/put'
require 'lib/helpers'

RSpec.describe '#auth_game_container_metadata_put' do
  context 'lambda_result' do
    let(:event) { { 'body' =>  post_body } }
    let(:lambda_result) { auth_game_container_metadata_put_handler(event: event, context: '') }
    let(:valid_uuid) { '87d2ebbf-3016-4ab8-97e6-c06e410b3359' }
    let(:task_arn) { Faker::Internet.ip_v4_address }
    let(:invalid_uuid) { SecureRandom.uuid }
    let(:valid_post) { JSON.generate({ uuid: valid_uuid, taskArn: task_arn }) }
    let(:invalid_post) { JSON.generate({ doobar: "foo", uuid: invalid_uuid, taskArn:'foo' }) }
    let(:post_body) { valid_post }
    let(:ddb_response) { File.read('spec/mocks/game/ddb/update-with-container-metadata.json') }

    before(:all) do
#      webmock_log_request
      $stash = $ddb_game_manager
      $ddb_game_manager = DynamodbGameManager.new()
    end

    after(:all) do
      $ddb_game_manager = $stash
    end

    before(:each) do
      stub_request(:post, "http://localhost:8000/")
        .to_return(status: 200, body: ddb_response , headers: {})
    end

    describe 'for the post response' do
      it_behaves_like 'lambda function'
    end

    describe 'for the body' do
      describe 'for a valid update' do
        it 'it succeeds' do
          #WebMock.after_request do |request_signature, response|
          #  puts "Request #{request_signature} was made and #{response.body} was returned"
          #end
          expect(lambda_result[:statusCode]).to eq 200
        end
      end

      describe 'for invalid update' do
        describe 'with missing properties' do
          let(:post_body) { JSON.generate({ taskArn:'foo' }) }
          it 'does not lint' do
            expect(lambda_result[:statusCode]).to eq 400
          end
        end
        describe 'with extra properties' do
          let(:post_body) { JSON.generate({ uuid: SecureRandom.uuid, taskArn:'foo', blah: 'bar' }) }
          it 'does not lint' do
            expect(lambda_result[:statusCode]).to eq 400
          end
        end
        describe 'with invalid json' do
          let(:post_body) { File.read('spec/mocks/game/invalid.json') }
          it 'does not lint' do
            expect(lambda_result[:statusCode]).to eq 400
          end
        end
      end
    end
  end
end
