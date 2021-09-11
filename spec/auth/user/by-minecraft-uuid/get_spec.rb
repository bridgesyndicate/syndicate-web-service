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
          expect(JSON.parse(lambda_result[:body])['user']['minecraftUUID']).
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
          expect(lambda_result[:statusCode]).to eq 404
        end
        it 'returns a kick code' do
          expect(JSON.parse(lambda_result[:body])['kick_code']).to match KICK_CODE_REGEX
        end
      end
    end
  end
end
