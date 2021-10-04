load 'spec_helper.rb'
require 'lambda/auth/register/by-kick-code/post'
require 'lib/helpers'

RSpec.describe '#kick_code_post' do
  context 'lambda_result' do
    let(:kick_code) { SecureRandom.alphanumeric.chop.concat(%w/0 2 4 6 8/.sample) }
    let(:discord_id) { SecureRandom.random_number(10**16) }
    let(:event) {
      {
        'pathParameters' => {
          'proxy' => "#{kick_code}/discord-id/#{discord_id}"
        }
      }
    }
    let(:lambda_result) { auth_register_by_kick_code_post_handler(event: event, context: '') }
    before(:each) {
      stub_request(:post, "http://localhost:8000/").
        to_return(status: 200, body: "{}", headers: {})
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

    describe 'resource formatting checks' do
      describe 'for invalid kick_code format' do
        let(:kick_code) { SecureRandom.alphanumeric[0,rand(15)+1] }

        it 'it is bad request' do
          expect(lambda_result[:statusCode]).to eq 400
        end
      end
      describe 'for invalid id format' do
        let(:discord_id) { 'abcd' }

        it 'it is bad request' do
          expect(lambda_result[:statusCode]).to eq 400
        end
      end
    end

    describe 'for a kick code in the database' do
      it 'returns a 200' do
        expect(lambda_result[:statusCode]).to eq 200
      end
    end
    describe 'for a kick code not in the database' do
      let(:kick_code) { SecureRandom.alphanumeric.chop.concat(%w/1 3 5 7 9/.sample) }
      it 'returns not found' do
        expect(lambda_result[:statusCode]).to eq 404
      end
    end
  end
end
