load 'spec_helper.rb'
require 'lambda/auth/user/by-minecraft-name/get'
require 'lib/helpers'

# <WebMock::RequestSignature:0x00005632bca87218 @method=:get, @uri=#<Addressable::URI:0x19b4 URI:https://api.mojang.com:443/users/profiles/minecraft/ep1cpr0gamer>, @body=nil, @headers={"User-Agent"=>"Faraday v2.2.0", "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "Accept"=>"*/*"}>
# <WebMock::Response:0x00005632bca42b18 @headers={"Content-Type"=>"application/json", "Content-Length"=>"63", "Connection"=>"keep-alive", "Accept-Ranges"=>"bytes", "Cache-Control"=>"no-store", "Date"=>"Sun, 13 Feb 2022 01:51:48 GMT", "Server"=>"Restlet-Framework/2.4.1", "Vary"=>"Accept-Charset, Accept-Encoding, Accept-Language, Accept", "X-Cache"=>"Miss from cloudfront", "Via"=>"1.1 28663e5849ed20a9d037ca8066957990.cloudfront.net (CloudFront)", "X-Amz-Cf-Pop"=>"SFO5-C1", "X-Amz-Cf-Id"=>"tudCVPkeMAuYpt739H_KeGpcU6zFMrVhtaT56yTc2YNmNcEOKB2lIw=="}, @status=[200, "OK"], @body="{\"name\":\"ep1cpr0gamer\",\"id\":\"9bf95247d0ed4c22877e0ac31532ade7\"}", @exception=nil, @should_timeout=nil>

# <WebMock::Response:0x00005641d79b9bb8 @headers={"Connection"=>"keep-alive", "Accept-Ranges"=>"bytes", "Cache-Control"=>"no-store", "Date"=>"Sun, 13 Feb 2022 01:44:31 GMT", "Server"=>"Restlet-Framework/2.4.1", "Vary"=>"Accept-Charset, Accept-Encoding, Accept-Language, Accept", "X-Cache"=>"Miss from cloudfront", "Via"=>"1.1 e2b6596be074ad87bd3300d4df7735b4.cloudfront.net (CloudFront)", "X-Amz-Cf-Pop"=>"SFO5-P2", "X-Amz-Cf-Id"=>"ma51-3suOT-yEhOXe3BAWzRGeYyrOGDm6Px2qVU7G968CVp_gyInPg=="}, @status=[204, "No Content"], @body=nil, @exception=nil, @should_timeout=nil>

# webmock_log_request

RSpec.describe '#auth_user_by_minecraft_name_get' do
  context 'lambda_result' do
    let(:minecraft_name) { Faker::Internet.username.gsub('.','') }
    let(:event) {
      {
        'pathParameters' => {
          'proxy' => minecraft_name
        }
      }
    }
    let(:lambda_result) {
      auth_user_by_minecraft_name_get_handler(event: event, context: '')
    }

    let(:response) { File.read('spec/mocks/user/by-minecraft-name/dynamo-get-found.json') }

    let(:mojang_response) {
      {
        name: 'ep1cpr0gamer',
        id: '9bf95247d0ed4c22877e0ac31532ade7'
      }
    }

    before(:each) do
      stub_request(:get, /api.mojang.com/)
        .to_return(status: 200, body: JSON.pretty_generate(mojang_response))
      stub_request(:post, "http://localhost:8000/")
        .to_return(status: 200,
                   body: response.sub('MINECRAFT_UUID',
                                      seeded_random_uuid($example_name).to_s)
                  )
    end

    describe 'for the get response body' do
      it_behaves_like 'lambda function'
    end

    describe 'for a username with invalid characters' do
      let(:bad_chars) { %w/- . + ; :/ }
      let(:minecraft_name) { Faker::Internet.username.gsub('.','')
                               .concat(bad_chars.sample) }

      it 'returns a 400' do
        expect(lambda_result[:statusCode]).to eq 400
      end
    end

    describe 'for a username that mojang cannot find' do
      before(:each) do
        stub_request(:get, /api.mojang.com/)
          .to_return(status: 204, body: nil)
      end
      it 'returns a 404' do
        expect(lambda_result[:statusCode]).to eq 404
      end
      it 'the reason is no mojang results' do
        expect(JSON.parse(lambda_result[:body])['reason'])
          .to eq 'Mojang cannot find this username'
      end
    end

    describe 'for a username that mojang has' do

      describe 'that is in our dynamodb' do
        it 'returns 200' do
          expect(lambda_result[:statusCode]).to eq 200
        end
        it 'the body is a hash' do
          expect(JSON.parse(lambda_result[:body]))
            .to be_a Hash
        end
        it 'the body has a discord id' do
          expect(JSON.parse(lambda_result[:body])['user']['discord_id'])
            .to match /\d+/
        end
      end

      describe 'that is not in our dynamodb' do
        let(:response) { File.read('spec/mocks/user/by-discord-id/dynamo-get-404.json') }
        it 'returns a 404' do
          expect(lambda_result[:statusCode]).to eq 404
        end
        it 'the reason is no local user' do
          expect(JSON.parse(lambda_result[:body])['reason'])
            .to eq 'Syndicate cannot find this username'
        end
      end
    end
  end
end
