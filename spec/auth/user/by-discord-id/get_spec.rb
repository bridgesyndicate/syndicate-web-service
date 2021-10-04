load 'spec_helper.rb'
require 'lambda/auth/user/by-discord-id/get'
require 'lib/helpers'

# webmock_log_request

RSpec.describe '#auth_user_by_minecraft_uuid_get' do
  context 'lambda_result' do
    let(:discord_id) { seeded_random_integer($example_name).to_s }
    let(:event) {
      {
        'pathParameters' => {
          'proxy' => discord_id
        }
      }
    }
    let(:lambda_result) { auth_user_by_discord_id_get_handler(event: event, context: '') }
    before(:example) {
      response = File.read('spec/mocks/user/by-discord-id/dynamo-get-found.json')
      stub_request(:post, "http://localhost:8000/")
        .to_return(status: 200,
                   body: response.sub('REPLACE_ME',
                                      seeded_random_integer($example_name).to_s)
                  )
    }

    describe 'for the get response body' do
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

    describe 'for the get response' do
      describe 'for a valid user' do
        it 'it succeeds' do
          expect(lambda_result[:statusCode]).to eq 200
        end
        it 'returns a user record' do
          body = JSON.parse(lambda_result[:body])
          expect(body['minecraft_uuid']).
            to match UUID_REGEX
          expect(body['discord_id']).
            to eq discord_id
        end
      end
      describe 'for an invalid discord id' do
        let(:discord_id) { 'abcd' }
        it 'returns 400' do
          expect(lambda_result[:statusCode]).to eq 400
        end
      end
      describe 'for an invalid user' do
        it 'returns 404' do
          stub_request(:post, "http://localhost:8000/")
            .to_return(status: 200,
                       body: File.read('spec/mocks/user/by-discord-id/dynamo-get-404.json'))
          expect(lambda_result[:statusCode]).to eq 404
        end
      end
    end
  end
end
