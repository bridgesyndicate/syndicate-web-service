load 'spec_helper.rb'
require 'lambda/auth/warp/post'
require 'json-schema'
require 'lib/schema/game_post'
require 'lib/helpers'

RSpec.describe '#warp_post' do
  context 'lambda_result' do
    let(:discord_id) { seeded_random_integer($example_name).to_s }
    let(:game_uuid) { SecureRandom.uuid }
    let (:post_body) { nil }
    let (:game_in_progress) { File.read('spec/mocks/game/ddb/found.json') }
    let (:game_over) { File.read('spec/mocks/game/ddb/found-after-game.json') }
    let (:game_not_found) { File.read('spec/mocks/game/ddb/not-found.json') }

    after(:all) do
      $ddb_game_manager = $stash
    end

    before(:all) do
      #webmock_log_request
      $stash = $ddb_game_manager
      $ddb_game_manager = DynamodbGameManager.new()
    end

    let(:event) {
      {
        'body' => post_body,
        'pathParameters' => {
          'proxy' => "#{discord_id}/game_uuid/#{game_uuid}"
        }
      }
    }

    let(:lambda_result) { auth_warp_post_handler(event: event, context: '') }

    before(:each) {
      response = File.read('spec/mocks/user/by-discord-id/dynamo-get-found.json')
      stub_request(:post, "http://localhost:8000/")
        .to_return(status: 200,
                   body: response.sub('REPLACE_ME',
                                      seeded_random_integer($example_name).to_s)
                  )
        .to_return(status: 200,
                   body: game_in_progress
                  )
    }

    describe 'for the post response' do
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
        it 'returns 200, valid' do
          expect(lambda_result[:statusCode]).to eq 200
        end
      end

      describe 'for a game that has ended' do
        before(:each) do
          response = File.read('spec/mocks/user/by-discord-id/dynamo-get-found.json')
          stub_request(:post, "http://localhost:8000/")
            .to_return(status: 200,
                       body: response.sub('REPLACE_ME',
                                          seeded_random_integer($example_name).to_s)
                      )
            .to_return(status: 200,
                       body: game_over
                      )
        end
        it 'returns 404' do
          expect(lambda_result[:statusCode]).to eq 404
          expect(JSON.parse(lambda_result[:body])['reason']).to eq 'Game is over'
        end
      end

      describe 'for a game that does not exist' do
        before(:each) do
          response = File.read('spec/mocks/user/by-discord-id/dynamo-get-found.json')
          stub_request(:post, "http://localhost:8000/")
            .to_return(status: 200,
                       body: response.sub('REPLACE_ME',
                                          seeded_random_integer($example_name).to_s)
                      )
            .to_return(status: 200,
                       body: game_not_found
                      )
        end
        it 'returns 404' do
          expect(lambda_result[:statusCode]).to eq 404
          expect(JSON.parse(lambda_result[:body])['reason']).to eq 'Game not found'
        end
      end
    end
  end
end
