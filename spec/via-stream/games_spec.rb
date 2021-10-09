load 'spec_helper.rb'
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
    it 'calls sqs' do
      expect($sqs_manager).to receive(:enqueue)
      handler(event: event, context: {})
    end
  end
end
