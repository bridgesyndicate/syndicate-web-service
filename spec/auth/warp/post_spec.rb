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
  end
end
