load 'spec_helper.rb'
require 'lambda/auth/game/put'
require 'lib/helpers'
require 'digest'

RSpec.describe '#auth_game_put' do
  context 'lambda_result' do
    let(:event) { { 'body' =>  post_body } }
    let(:post_body) { File.read('spec/mocks/game/valid-put.json')}
    let(:lambda_result) { auth_game_put_handler(event: event, context: '') }

    describe 'for the post response' do
      it_behaves_like 'lambda function'
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
