load 'spec_helper.rb'
require 'lambda/auth/game/container_metadata/put'
require 'lib/helpers'

RSpec.describe '#auth_game_container_metadata_put' do
  context 'lambda_result' do
    let(:event) { { 'body' =>  post_body } }
    let(:lambda_result) { auth_game_container_metadata_put_handler(event: event, context: '') }
    let(:valid_uuid) { SecureRandom.uuid }
    let(:invalid_uuid) { SecureRandom.uuid }
    let(:valid_post) { JSON.generate({ uuid: valid_uuid, taskArn:'foo' }) }
    let(:invalid_post) { JSON.generate({ doobar: "foo", uuid: invalid_uuid, taskArn:'foo' }) }
    let(:post_body) { valid_post }

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
