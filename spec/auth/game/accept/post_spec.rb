load 'spec_helper.rb'
require 'lambda/auth/game/accept/post'
require 'json-schema'
require 'lib/helpers'

RSpec.describe '#accept post' do
  context 'lambda_result' do
    let(:discord_id) { seeded_random_integer($example_name).to_s }
    let(:game_uuid) { 'dea056d3-b352-49ae-a2e1-10e37586f091' }
    let (:post_body) {nil}
    let(:event) {
      {
        'body' => post_body,
        'pathParameters' => {
          'proxy' => "#{game_uuid}/foobar/#{discord_id}"
        }
      }
    }

    let(:lambda_result) { auth_game_accept_post_handler(event: event, context: '') }

    before(:all) do
      #webmock_log_request
      $stash = $ddb_game_manager
      $ddb_game_manager = DynamodbGameManager.new()
    end

    before(:each) do
      stub_request(:post, "http://localhost:8000/")
        .to_return(status: 200,
                   body: File.read('spec/mocks/ddb/add_accepted_by_discord_id-1x1.json'),
                   headers: {})
    end

    after(:all) do
      $ddb_game_manager = $stash
    end

    describe 'for the post response' do
      before(:each) do
        sqs_ret = OpenStruct.new( message_id: SecureRandom.uuid)
        expect($sqs_manager).to receive(:enqueue).and_return(sqs_ret)
      end

      it_behaves_like 'lambda function'
    end

    describe 'with invalid input' do

      describe 'an invalid discord_id' do
        let(:discord_id) {"invalid discord_id"}
        it 'returns 400, invalid discord id' do
          expect(lambda_result[:statusCode]).to eq 400
        end
      end

      describe 'an invalid game uuid' do
        let(:game_uuid) { 'invalid game uuid' }
        it 'returns 400, invalid game uuid' do
          expect(lambda_result[:statusCode]).to eq 400
        end
      end

      describe 'a post body for a method that does not require one' do
        let(:post_body) { 'this should be empty' }
        it 'returns 400, invalid post body length > 0' do
          expect(lambda_result[:statusCode]).to eq 400
        end
      end

      describe 'for a proper request' do
        before(:each) do
          sqs_ret = OpenStruct.new( message_id: SecureRandom.uuid)
          expect($sqs_manager).to receive(:enqueue).and_return(sqs_ret)
        end

        it 'returns 200, valid' do
          expect(lambda_result[:statusCode]).to eq 200
        end
      end

      describe 'for a 4x4 with two acceptances on the same team it does not queue' do
        before(:each) do
          stub_request(:post, "http://localhost:8000/")
            .to_return(status: 200,
                       body: File.read('spec/mocks/ddb/add_accepted_by_discord_id-4x4-not-accepted.json'),
                       headers: {})
        end

        it 'returns a 200' do
          expect(lambda_result[:statusCode]).to eq 200
        end
      end

      describe 'for a 4x4 with two acceptances on the same team it does not queue' do
        before(:each) do
          sqs_ret = OpenStruct.new( message_id: SecureRandom.uuid)
          expect($sqs_manager).to receive(:enqueue).and_return(sqs_ret)
          stub_request(:post, "http://localhost:8000/")
            .to_return(status: 200,
                       body: File.read('spec/mocks/ddb/add_accepted_by_discord_id-4x4-accepted.json'),
                       headers: {})
        end

        it 'returns a 200' do
          expect(lambda_result[:statusCode]).to eq 200
        end
      end
    end
  end
end
