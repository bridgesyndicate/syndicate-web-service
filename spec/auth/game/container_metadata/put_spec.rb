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

    before(:each) {
      stub_request(:post, "https://ecs.us-west-2.amazonaws.com/")
        .to_return(status: 200, body: File.read('spec/mocks/web-mock-ecs-describe-tasks.json'), headers: {})
      stub_request(:post, "https://ec2.us-west-2.amazonaws.com/")
        .to_return(status: 200, body: File.read('spec/mocks/web-mock-ec2-describe-network-interface.xml'), headers: {})
      stub_request(:post, 'https://sqs.us-west-2.amazonaws.com/595508394202/syndicate_production_player_messages')
        .to_return(status: 200, body: File.read('spec/mocks/web-mock-sqs-enqueue-production-player-messages.xml'), headers: {})
      stub_request(:post, 'https://sqs.us-west-2.amazonaws.com/595508394202/syndicate_production_games')
        .to_return(status: 200, body: File.read('spec/mocks/web-mock-sqs-enqueue-production-player-messages.xml'), headers: {})
    }

    describe 'for the post response' do
      it 'returns a well-formed response for Lambda' do
        expect(lambda_result.class).to eq Hash
      end

      it 'has 3 keys' do
        expect(lambda_result.keys.size).to eq 3
      end

      it 'body is a string' do
        expect(lambda_result[:body].class).to eq String
      end

      it 'body is a JSON string' do
        expect(JSON.parse(lambda_result[:body]).class).to eq Hash
      end
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
