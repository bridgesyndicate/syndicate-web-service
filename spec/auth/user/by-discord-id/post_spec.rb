load 'spec_helper.rb'
require 'lambda/auth/user/by-discord-id/post'
require 'json-schema'
#require 'lib/schema/user/by-discord-id/post'
require 'lib/schema/user/by-discord-id/response'
require 'lib/helpers'

# webmock_log_request

RSpec.describe '#auth_user_by_minecraft_uuid_post' do
  context 'lambda_result' do
    let(:prefix) { 'spec/mocks/user/by-discord-id/ddb-' }
    let(:event) { { 'body' =>  File.read(post_file) } }
    let(:post_file) {'spec/mocks/user/by-discord-id/valid-post.json'}
    let(:lambda_result) {
      auth_user_by_discord_id_post_handler(event: event, context: '')
    }
    before(:each) do
      stub_request(:post, "http://localhost:8000/")
        .to_return(status: 200,
                   body: File.read("#{prefix}246107858712788993.json"),
                   headers: {})
        .to_return(status: 200,
                   body: File.read("#{prefix}417766998471213061.json"),
                   headers: {})
        .to_return(status: 200,
                   body: File.read("#{prefix}562075850883989514.json"),
                   headers: {})
        .to_return(status: 200,
                   body: File.read("#{prefix}882712836852301886.json"),
                   headers: {})
    end

    describe 'for the get response body' do
      it_behaves_like 'lambda function'
    end

    describe 'for the post response' do
      describe 'for a valid post' do
        it 'succeeds' do
          expect(lambda_result[:statusCode]).to eq 200
        end
        it 'returns a hash of user records with elo' do
          body = JSON.parse(lambda_result[:body])
          expect(JSON::Validator
                   .fully_validate(UserByDiscordIdResponse.schema, body))
            .to eq []
          expect(body["246107858712788993"]['elo']).to eq 1654
          expect(body["882712836852301886"]['elo']).to eq 1698
          expect(body["417766998471213061"]['elo']).to eq 114
          expect(body["562075850883989514"]['elo']).to eq 961
        end
      end
      describe 'for an invalid post' do
        let(:post_file) {'spec/mocks/user/by-discord-id/invalid-post.json'}
        it 'returns 400' do
          expect(lambda_result[:statusCode]).to eq 400
        end
      end
      describe 'for a post with users who do not yet have elo' do
        before(:each) do
          stub_request(:post, "http://localhost:8000/")
            .to_return(status: 200,
                       body: File.read("#{prefix}246107858712788993.json"),
                       headers: {})
            .to_return(status: 200,
                       body: File.read("#{prefix}484145959287390270.json"),
                       headers: {})
            .to_return(status: 200,
                       body: File.read("#{prefix}417766998471213061.json"),
                       headers: {})
            .to_return(status: 200,
                       body: File.read("#{prefix}562075850883989514.json"),
                       headers: {})
        end
        let(:post_file) {'spec/mocks/user/by-discord-id/valid-post-with-new-user.json'}

        it 'fails' do
          expect{
            lambda_result[:statusCode]
          }.to raise_error DynamodbUserManager::NoEloError
        end
      end
    end
  end
end
