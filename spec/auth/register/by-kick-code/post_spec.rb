load 'spec_helper.rb'
require 'lambda/auth/register/by-kick-code/post'
require 'lib/helpers'

RSpec.describe '#kick_code_post' do
  context 'lambda_result' do
    let(:kick_code) { seeded_random_kick_code($example_name) }
    let(:discord_id) { seeded_random_integer($example_name) }
    let(:event) {
      {
        'pathParameters' => {
          'proxy' => "#{kick_code}/discord-id/#{discord_id}"
        }
      }
    }
    let(:lambda_result) { auth_register_by_kick_code_post_handler(event: event, context: '') }
    before(:each) {
      stub_request(:post, "http://localhost:8000/")
        .to_return(status: 200, body: File.read('spec/mocks/register/by-kick-code/success.json'), headers: {})
    }

    describe 'for the post response' do
      it_behaves_like 'lambda function'
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
      it 'returns not found' do
        stub_request(:post, "http://localhost:8000/")
          .to_return(status: 400, body: File.read('spec/mocks/register/by-kick-code/failure.json'), headers: {})
        expect(lambda_result[:statusCode]).to eq 404
      end
    end
  end
end
