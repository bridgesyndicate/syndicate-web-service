load 'spec_helper.rb'
require 'lambda/auth/warp/post'
require 'json-schema'
require 'lib/schema/game_post'
require 'lib/helpers'

RSpec.describe '#warp_post' do
  context 'lambda_result' do
    let(:discord_id) { seeded_random_integer($example_name).to_s }
    let(:event) {
      {
        'body' => File.read(post_file),
        'pathParameters' => {
          'proxy' => "#{discord_id}/foobar/#{SecureRandom.uuid}"
        }
      }
    }
    
    let(:lambda_result) { auth_warp_post_handler(event: event, context: '') }
    let(:post_file) {'spec/mocks/game/valid-duel-post.json'}

    before(:example) {
      response = File.read('spec/mocks/user/by-discord-id/dynamo-get-found.json')
      stub_request(:post, "http://localhost:8000/")
        .to_return(status: 200,
                   body: response.sub('REPLACE_ME',
                                      seeded_random_integer($example_name).to_s)
                  )
    }

    describe 'for the post response' do
      it_behaves_like 'lambda function'
    end

    describe 'for response 400' do
      let(:discord_id) {"invalid discord_id"}
      it 'returns 400, invalid discord id' do
          expect(lambda_result[:statusCode]).to eq 400
      end

      let(:invalid_uuid) {SecureRandom.uuid}
      it 'returns 400, invalid game uuid' do
          expect(lambda_result[:statusCode]).to eq 400
      end

      let(:post_file) {'spec/mocks/game/valid-duel-post.json'}
      it 'returns 400, post body length > 0' do
          expect(lambda_result[:statusCode]).to eq 400
      end
    end

    describe `for response 200` do
      let(:discord_id) {"240177490906054658"}
      let(:valid_uuid) {"87d2ebbf-3016-4ab8-97e6-c06e410b3359"}
      let (:post_body) {""}
      it 'returns 200, valid' do
          expect(lambda_result[:statusCode]).to eq 200
      end
    end
  end
end
