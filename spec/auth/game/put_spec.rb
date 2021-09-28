load 'spec_helper.rb'
require 'lambda/auth/game/put'
require 'lib/helpers'
require 'digest'

RSpec.describe '#auth_game_put' do
  context 'lambda_result' do
    let(:event) { { 'body' =>  post_body } }
    let(:post_body) { File.read('spec/mocks/game/valid-put.json')}
    let(:lambda_result) { auth_game_put_handler(event: event, context: '') }

    before(:each) {
      response = File.read('spec/mocks/web-mock-sqs-enqueue-delayed_warps.xml')
      ENV['srand'] = rand(2**32).to_s
      message = get_srandom_minecraft_uuids.to_json
      response.sub!('REPLACE_ME', Digest::MD5.hexdigest(message))
      stub_request(:post, 'https://sqs.us-west-2.amazonaws.com/595508394202/syndicate_production_delayed_warps')
        .to_return(status: 200, body: response, headers: {})
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
