load 'spec_helper.rb'
require 'lambda/auth/game/post'
require 'json-schema'
require 'lib/schema/game_post'
require 'lib/helpers'

RSpec.describe '#game_post' do
  context 'lambda_result' do
    let(:event) { { 'body' =>  File.read(post_file) } }
    let(:lambda_result) { auth_game_post_handler(event: event, context: '') }
    let(:post_file) {'spec/mocks/game/valid-duel-post.json'}

    before(:each) {
      body = File.read('spec/mocks/user/by-minecraft-uuid/dynamo-get-found.json')
      stub_request(:post, "http://localhost:8000/").
        to_return(status: 200, body: body, headers: {})
    }

    describe 'for the post response' do
      it_behaves_like 'lambda function'
    end

    describe 'for the post body' do
      describe 'for game post with unvalidated players' do
        it 'returns 404' do
          stub_request(:post, "http://localhost:8000/")
            .to_return(status: 200, body: File.read('spec/mocks/user/by-discord-id/dynamo-get-404.json'), headers: {})
            .to_return(status: 200, body: File.read('spec/mocks/user/by-minecraft-uuid/dynamo-get-found.json'), headers: {})
          expect(lambda_result[:statusCode]).to eq 404
        end
        it 'states that users must be verified' do
          stub_request(:post, "http://localhost:8000/")
            .to_return(status: 200, body: File.read('spec/mocks/user/by-discord-id/dynamo-get-404.json'), headers: {})
            .to_return(status: 200, body: File.read('spec/mocks/user/by-minecraft-uuid/dynamo-get-found.json'), headers: {})
          expect(JSON.parse(lambda_result[:body])['reason']).to eq 'All discord users must be verified.'
        end
      end
      describe 'for game post with a duplicate player' do
        let(:post_file) {'spec/mocks/game/dup-post.json'}
        it 'returns 400' do
          expect(lambda_result[:statusCode]).to eq 400
        end
        it 'states that users must be verified' do
          expect(JSON.parse(lambda_result[:body])['reason']).to eq 'Payload json does not contain at least two discord users.'
        end
      end
      describe 'for a valid duel game post, one accepted player' do
        it 'succeeds' do
          expect(lambda_result[:statusCode]).to eq 200
        end
        it 'returns a game with a uuid' do
          expect(JSON.parse(lambda_result[:body])['game']['uuid']).
            to match UUID_REGEX
        end
        it 'adds adds blue_team_minecraft_uuids and red_team_minecraft_uuids' do
          expect(JSON.parse(lambda_result[:body])['game']['blue_team_minecraft_uuids'].size).
            to eq JSON.parse(lambda_result[:body])['game']['blue_team_discord_ids'].size
        end
      end

      describe 'for a queue-generated game, two accepted players' do
        before(:each) {
          ENV['srand'] = "10"
          response = File.read('spec/mocks/web-mock-sqs-enqueue-response.xml')
          response.sub!('REPLACE_ME', '0b9246244abe9701b361e2199479f263')
          stub_request(:post, 'https://sqs.us-west-2.amazonaws.com/595508394202/syndicate_production_games')
            .to_return(status: 200, body: response, headers: {})
        }
        let(:post_file) {'spec/mocks/game/valid-queue-post.json'}
        it 'succeeds' do
          expect(lambda_result[:statusCode]).to eq 200
        end
        it 'returns a game with a uuid' do
          expect(JSON.parse(lambda_result[:body])['game']['uuid']).
            to match UUID_REGEX
        end
        it 'adds adds blue_team_minecraft_uuids and red_team_minecraft_uuids' do
          expect(JSON.parse(lambda_result[:body])['game']['blue_team_minecraft_uuids'].size).
            to eq JSON.parse(lambda_result[:body])['game']['blue_team_discord_ids'].size
        end
      end

      describe 'for invalid game posts' do
        describe 'with missing properties' do
          let(:post_file) { 'spec/mocks/game/missing-list.json' }
          it 'does not lint' do
            expect(lambda_result[:statusCode]).to eq 400
          end
          it 'returns an empty body' do
            expect( JSON.parse(lambda_result[:body])['reason'] ).to eq 'Payload json does not validate against schema.'
          end
        end
        describe 'with extra properties' do
          let(:post_file) { 'spec/mocks/game/added-foo.json' }
          it 'does not lint' do
            expect(lambda_result[:statusCode]).to eq 400
          end
        end
        describe 'with invalid json' do
          let(:post_file) { 'spec/mocks/game/invalid.json' }
          it 'does not lint' do
            expect(lambda_result[:statusCode]).to eq 400
          end
        end
      end
    end
  end
end
