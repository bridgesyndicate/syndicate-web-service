load 'spec_helper.rb'
require 'helpers'
require 'dynamo_client.rb'

RSpec.describe '#dynamodb_user_manager_spec' do
  let(:users) { [SecureRandom.random_number(10 ** 24)]}
  let(:response_body_file_1) { 'spec/mocks/user/by-discord-id/ddb-882712836852301886.json'}
  let(:response_body_file_2) { 'spec/mocks/user/by-discord-id/ddb-246107858712788993.json'}
  before(:each) do
    stub_request(:post, "http://localhost:8000/")
      .to_return(status: 200, body: File.read(response_body_file_1))
      .to_return(status: 200, body: File.read(response_body_file_2))
  end

  describe 'for a batch that has one record' do
    let(:response_body_file_2) { '/dev/null' }
    it 'has valid results' do
      res = $ddb_user_manager.batch_get_by_discord_ids(users)
      expect(res.to_json).to be_a String
      json = JSON.parse(res.to_json)
      key = json.keys.first
      expect(json[key]).to be_a Integer
      expect(json[key]).to equal 1698
    end
  end

  describe 'for a batch that has one record without elo' do
    let(:response_body_file_1) { 'spec/mocks/user/by-discord-id/ddb-882712836852301886-no-elo.json' }
    let(:response_body_file_2) { '/dev/null' }
    it 'has valid results' do
      res = $ddb_user_manager.batch_get_by_discord_ids(users)
      expect(res.to_json).to be_a String
      json = JSON.parse(res.to_json)
      key = json.keys.first
      expect(json[key]).to be nil
    end
  end

  describe 'for a batch that has a user with two records, one with elo, one without' do
    let(:users) { 2.times.map{ SecureRandom.random_number(10 ** 24) } }
    let(:response_body_file_1) { 'spec/mocks/user/by-discord-id/returns-two-records.json' }
    let(:response_body_file_2) { 'spec/mocks/user/by-discord-id/ddb-882712836852301886.json'}

    it 'has valid results' do
      res = $ddb_user_manager.batch_get_by_discord_ids(users)
      expect(res.to_json).to be_a String
      json = JSON.parse(res.to_json)
      key = json.keys.first
      expect(json[key]).to equal 1012
      key = json.keys[1]
      expect(json[key]).to equal 1698
    end
  end

  describe 'for a batch that has a user with two records, both with elo, use the first' do
    let(:users) { 2.times.map{ SecureRandom.random_number(10 ** 24) } }
    let(:response_body_file_2) { 'spec/mocks/user/by-discord-id/returns-two-records-with-elo.json' }
    let(:response_body_file_1) { 'spec/mocks/user/by-discord-id/ddb-882712836852301886.json'}

    it 'has valid results' do
      res = $ddb_user_manager.batch_get_by_discord_ids(users)
      expect(res.to_json).to be_a String
      json = JSON.parse(res.to_json)
      key = json.keys.first
      expect(json[key]).to equal 1698
      key = json.keys[1]
      expect(json[key]).to equal 2112
    end
  end
end
