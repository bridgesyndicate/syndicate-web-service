load 'spec_helper.rb'
require 'timecop'
require 'lambda/via-stream/games'
require 'lib/helpers'

RSpec.describe '#games stream' do
  let(:event) { JSON.parse(File.read'spec/mocks/stream/game-red-wins-2x2.json') }

  shared_examples 'end-of-match processing' do
    let(:hash) { Aws::DynamoDBStreams::AttributeTranslator
                   .from_event(event).first.to_h
    }
    it 'computes elo changes in pairs' do
      expect(compute_elo_changes(hash).size).to eq num_pairs
    end
    it 'computes the right winners' do
      expect(compute_elo_changes(hash).map {|p| p.winner.discord_name }).to eq winners
    end
    it 'computes the right losers' do
      expect(compute_elo_changes(hash).map {|p| p.loser.discord_name }).to eq losers
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

  describe 'red-wins-2x2' do
    let(:event) { JSON.parse(File.read'spec/mocks/stream/game-red-wins-2x2.json') }
    let(:num_pairs) {2}
    let(:winners) { %w/bdamja ken/ }
    let(:losers) { %w/viceversa ellis/ }
    it_behaves_like 'end-of-match processing'
  end

  describe 'blue-wins-1x1' do
    let(:event) { JSON.parse(File.read('spec/mocks/stream/game-blue-wins-1x1.json')) }
    let(:num_pairs) {1}
    let(:winners) { %w/viceversa/ }
    let(:losers) { %w/bdamja/ }
    it_behaves_like 'end-of-match processing'
  end

  describe 'red-wins-1x1' do
    let(:event) { JSON.parse(File.read('spec/mocks/stream/game-red-wins-1x1.json')) }
    let(:num_pairs) {1}
    let(:winners) { %w/bdamja/ }
    let(:losers) { %w/viceversa/ }
    it_behaves_like 'end-of-match processing'
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
      # https://github.com/travisjeffery/timecop/issues/41
      Timecop.freeze(Time.parse('Tue Oct 19 15:37:00 PDT 2021').utc)
      stub_request(:post, "http://localhost:8000/")
        .with(
          body: build_test_json(uuid: '2b7fa93b-f690-46b8-bfe6-a07b2ec42563',
                                 elo: '999'))
        .to_return(status: 200, body: "", headers: {})
      stub_request(:post, "http://localhost:8000/")
        .with(
          body: build_test_json(uuid: 'f0885cea-8291-4734-be1b-bf37f6bcab7c',
                                 elo: '1191'))
        .to_return(status: 200, body: "", headers: {})
      stub_request(:post, "http://localhost:8000/")
        .with(
          body: build_test_json(uuid: 'eb7fa93b-f690-46b8-bfe6-a07b2ec42563',
                                 elo: '2215'))
        .to_return(status: 200, body: "", headers: {})
      stub_request(:post, "http://localhost:8000/")
        .with(
          body: build_test_json(uuid: 'e1185cea-8291-4734-be1b-bf37f6bcab7c',
                                 elo: '2285'))
        .to_return(status: 200, body: "", headers: {})
    }
    it 'udpates ddb' do
      expect($sqs_manager).to receive(:enqueue).once
      handler(event: event, context: {})
    end
  end
end
