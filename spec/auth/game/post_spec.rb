load 'spec_helper.rb'
require 'lambda/auth/game/post'
require 'json-schema'
require 'lib/schema/game_post'
require 'lib/helpers'

RSpec.describe '#game_post' do
  context 'lambda_result' do
    let(:event) { { 'body' =>  File.read(post_file) } }
    let(:lambda_result) { auth_game_post_handler(event: event, context: '') }
    let(:post_file) {'spec/mocks/game/valid-post.json'}

    before(:each) {
      stub_request(:post, 'https://sqs.us-west-2.amazonaws.com/595508394202/syndicate_production_games')
        .to_return(status: 200, body: File.read('spec/mocks/web-mock-sqs-enqueue-production-games.xml'), headers: {})
    }

    describe 'for the post response' do
      it 'returns a well-formed response for Lambda' do
        #WebMock.after_request do |request_signature, response|
        #  puts "Request #{request_signature} was made and #{response.body} was returned"
        #end
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

    describe 'for the post body' do
      describe 'for a valid game post' do
        it 'it succeeds' do
          expect(lambda_result[:statusCode]).to eq 200
        end
        it 'returns a uuid' do
          expect(JSON.parse(lambda_result[:body])['uuid']).
            to match UUID_REGEX
        end
      end

      describe 'for invalid game posts' do
        describe 'with missing properties' do
          let(:post_file) { 'spec/mocks/game/missing-list.json' }
          it 'does not lint' do
            expect(lambda_result[:statusCode]).to eq 400
          end
          it 'returns an empty body' do
            expect(lambda_result[:body]).to eq '{}'
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
