load 'spec_helper.rb'
require 'lambda/auth/user/by-minecraft-uuid/get'
require 'lib/helpers'

RSpec.describe '#auth_user_by_minecraft_uuid_get' do
  context 'lambda_result' do
    let(:uuid) { SecureRandom.uuid.chop.concat(%w/0 2 4 6 8/.sample) }
    let(:event) {
      {
        'pathParameters' => {
          'proxy' => uuid
        }
      }
    }
    let(:lambda_result) { auth_user_by_minecraft_uuid_get_handler(event: event, context: '') }
    before(:example) {
      response = File.read('spec/mocks/user/by-minecraft-uuid/dynamo-get-found.json')
      stub_request(:post, "http://localhost:8000/")
        .to_return(status: 200,
                   body: response.sub('MINECRAFT_UUID',
                                      seeded_random_uuid($example_name).to_s)
                  )
    }


    describe 'for the get response body' do
      it_behaves_like 'lambda function'
    end

    describe 'for the get response' do
      describe 'for a valid user' do
        it 'it succeeds' do
          expect(lambda_result[:statusCode]).to eq 200
        end
        it 'returns a user record' do
          expect(JSON.parse(lambda_result[:body])['user']['minecraft_uuid']).
            to match UUID_REGEX
        end
      end
      describe 'for an invalid uuid' do
        let(:uuid) { 'abcd' }
        it 'returns 400' do
          expect(lambda_result[:statusCode]).to eq 400
        end
      end
      describe 'for an invalid user' do
        let(:uuid) { SecureRandom.uuid.chop.concat(%w/1 3 5 7 9 a b c d e f/.sample) }
        it 'returns 404' do
          stub_request(:post, "http://localhost:8000/")
            .to_return(status: 200,
                       body: File.read('spec/mocks/user/by-discord-id/dynamo-get-404.json'))
          expect(lambda_result[:statusCode]).to eq 404
        end
        it 'returns a kick code' do
          stub_request(:post, "http://localhost:8000/")
            .to_return(status: 200,
                       body: File.read('spec/mocks/user/by-discord-id/dynamo-get-404.json'))
          expect(JSON.parse(lambda_result[:body])['kick_code']).to match KICK_CODE_REGEX
        end
      end
      describe 'for a banned user' do
        let(:response) { File.read('./spec/mocks/user/by-minecraft-uuid/dynamo-get-banned.json') }
        it 'returns 403' do
          stub_request(:post, "http://localhost:8000/")
            .to_return(status: 200,
                       body: response)
          expect(lambda_result[:statusCode]).to eq 403
        end
      end
    end
  end
end
