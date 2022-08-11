load 'spec_helper.rb'
require 'helpers'
require 'dynamo_client.rb'

RSpec.describe '#dynamodb_user_manager_spec' do
  let(:users) { [SecureRandom.random_number(10 ** 24).to_s] }
  let(:user8) { '882712836852301886' }
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
      obj = JSON.parse(res.to_json)
      expect(obj.keys.size).to eq 1
      expect(obj[user8]['elo']).to be_a Integer
      expect(obj[user8]['elo']).to equal 1698
    end
  end

  describe 'for a batch that has one record without elo, expect STARTING_ELO' do
    let(:response_body_file_1) { 'spec/mocks/user/by-discord-id/ddb-882712836852301886-no-elo.json' }
    let(:response_body_file_2) { '/dev/null' }
    it 'has valid results' do
      res = $ddb_user_manager.batch_get_by_discord_ids(users)
      expect(res.to_json).to be_a String
      obj = JSON.parse(res.to_json)
      key = obj.keys.first
      expect(obj[key]).to be_a Hash
      expect(obj[key]['elo']).to eq STARTING_ELO
    end
  end

  describe 'for a batch that has a user with two records, one with elo, one without' do
    let(:users) { 2.times.map{ SecureRandom.random_number(10 ** 24) } }
    let(:response_body_file_1) { 'spec/mocks/user/by-discord-id/returns-two-records.json' }
    let(:response_body_file_2) { 'spec/mocks/user/by-discord-id/ddb-882712836852301886.json'}

    it 'has valid results' do
      res = $ddb_user_manager.batch_get_by_discord_ids(users)
      expect(res.to_json).to be_a String
      obj = JSON.parse(res.to_json)
      key = obj.keys.first
      expect(obj[key]['elo']).to equal STARTING_ELO
      key = obj.keys[1]
      expect(obj[key]['elo']).to equal 1698
    end
  end

  describe 'for a batch that has a user with two records, both with elo, use the first' do
    let(:users) { 2.times.map{ SecureRandom.random_number(10 ** 24) } }
    let(:response_body_file_2) { 'spec/mocks/user/by-discord-id/returns-two-records-with-elo.json' }
    let(:response_body_file_1) { 'spec/mocks/user/by-discord-id/ddb-882712836852301886.json'}

    it 'has valid results' do
      res = $ddb_user_manager.batch_get_by_discord_ids(users)
      expect(res.to_json).to be_a String
      obj = JSON.parse(res.to_json)
      key = obj.keys.first
      expect(obj[key]['elo']).to equal 1698
      key = obj.keys[1]
      expect(obj[key]['elo']).to equal 2112
    end
  end
end
