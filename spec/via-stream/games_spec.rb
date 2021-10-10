load 'spec_helper.rb'
require 'timecop'
require 'lambda/via-stream/games'
require 'lib/helpers'

RSpec.describe '#games stream' do
  let(:event) { JSON.parse(File.read('spec/mocks/stream/game-2x2.json')) }

  describe 'compute elo changes' do
    let(:hash) { Aws::DynamoDBStreams::AttributeTranslator
                   .from_event(event).first.to_h
    }
    it 'computes elo changes in pairs' do
      expect(compute_elo_changes(hash).size).to eq 2
    end
    it 'computes the right winners' do
      expect(compute_elo_changes(hash).map {|p| p.loser.discord_name }).to eq ['viceversa', 'ellis']
    end
    it 'computes the right losers' do
      expect(compute_elo_changes(hash).map {|p| p.winner.discord_name }).to eq ['bdamja', 'ken']
    end
    it 'increases the winners elo' do
      expect(compute_elo_changes(hash).map {|p| p.winner.end_elo - p.winner.start_elo })
        .to all(be_positive)
    end
    it 'decreases the losers elo' do
      expect(compute_elo_changes(hash).map {|p| p.loser.end_elo - p.loser.start_elo })
        .to all(be_negative)
    end
  end

  describe 'handler' do
    it 'calls dynamo' do
      expect($sqs_manager).to receive(:enqueue).once
      expect($ddb_user_manager).to receive(:batch_update).once
      handler(event: event, context: {})
    end
  end
  describe 'DynamoDDB calls' do
    before(:each) {
      Timecop.travel(Time.local(2021, 10, 19, 15, 37, 0))
      stub_request(:post, "http://localhost:8000/")
        .with(
          body: "{\"TableName\":\"syndicate_test_users\",\"Key\":{\"minecraft_uuid\":{\"S\":\"2b7fa93b-f690-46b8-bfe6-a07b2ec42563\"}},\"UpdateExpression\":\"SET #updated_at = :now, #elo = :elo\",\"ExpressionAttributeNames\":{\"#updated_at\":\"updated_at\",\"#elo\":\"elo\"},\"ExpressionAttributeValues\":{\":now\":{\"S\":\"2021-10-19T22:37:00Z\"},\":elo\":{\"N\":\"999\"}},\"ReturnValues\":\"ALL_NEW\"}")
        .to_return(status: 200, body: "", headers: {})
      stub_request(:post, "http://localhost:8000/")
        .with(
          body: "{\"TableName\":\"syndicate_test_users\",\"Key\":{\"minecraft_uuid\":{\"S\":\"f0885cea-8291-4734-be1b-bf37f6bcab7c\"}},\"UpdateExpression\":\"SET #updated_at = :now, #elo = :elo\",\"ExpressionAttributeNames\":{\"#updated_at\":\"updated_at\",\"#elo\":\"elo\"},\"ExpressionAttributeValues\":{\":now\":{\"S\":\"2021-10-19T22:37:00Z\"},\":elo\":{\"N\":\"1191\"}},\"ReturnValues\":\"ALL_NEW\"}")
        .to_return(status: 200, body: "", headers: {})
      stub_request(:post, "http://localhost:8000/")
        .with(
          body: "{\"TableName\":\"syndicate_test_users\",\"Key\":{\"minecraft_uuid\":{\"S\":\"eb7fa93b-f690-46b8-bfe6-a07b2ec42563\"}},\"UpdateExpression\":\"SET #updated_at = :now, #elo = :elo\",\"ExpressionAttributeNames\":{\"#updated_at\":\"updated_at\",\"#elo\":\"elo\"},\"ExpressionAttributeValues\":{\":now\":{\"S\":\"2021-10-19T22:37:00Z\"},\":elo\":{\"N\":\"2215\"}},\"ReturnValues\":\"ALL_NEW\"}")
        .to_return(status: 200, body: "", headers: {})
      stub_request(:post, "http://localhost:8000/")
        .with(
          body: "{\"TableName\":\"syndicate_test_users\",\"Key\":{\"minecraft_uuid\":{\"S\":\"e1185cea-8291-4734-be1b-bf37f6bcab7c\"}},\"UpdateExpression\":\"SET #updated_at = :now, #elo = :elo\",\"ExpressionAttributeNames\":{\"#updated_at\":\"updated_at\",\"#elo\":\"elo\"},\"ExpressionAttributeValues\":{\":now\":{\"S\":\"2021-10-19T22:37:00Z\"},\":elo\":{\"N\":\"2285\"}},\"ReturnValues\":\"ALL_NEW\"}")
        .to_return(status: 200, body: "", headers: {})
    }
    it 'udpates ddb' do
      expect($sqs_manager).to receive(:enqueue).once
      handler(event: event, context: {})
    end
  end
end
