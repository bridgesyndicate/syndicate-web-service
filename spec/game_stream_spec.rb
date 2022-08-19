load 'spec_helper.rb'
require 'lib/helpers'
require 'lib/game_stream'

describe 'GameStream' do
  context 'the player message' do
    let(:event) { JSON.parse(File.read('spec/mocks/stream/game-end-2x2-with-season.json')) }
    let(:game_stream) { GameStream.new(Aws::DynamoDBStreams::AttributeTranslator
                                         .from_event(event).first)
    }
    let(:json) { game_stream.batch.to_json }
    let(:parsed_json) { JSON.parse(json) }

    before(:each) { game_stream.compute_elo_changes }

    it 'is a list' do
      expect(game_stream.batch).to be_a Array
      expect(game_stream.batch.size).to eq 4
    end

    it 'converts to json ' do
      expect(json).to be_a String
    end

    it 'the json has two season pairs and two non-season pairs' do
      expect(parsed_json.map{ |p| p['season'] })
        .to eq [nil, nil, "season1", "season1"]
    end

    it 'has the expected elo' do
      parsed_json.each do |p|
        season = !!p['season']
        winner_start = season ? p['winner']['start_elo']['season'] :
                         p['winner']['start_elo']['elo']
        loser_start = season ? p['loser']['start_elo']['season'] :
                        p['loser']['start_elo']['elo']
        winner_end = p['winner']['end_elo']
        loser_end = p['loser']['end_elo']
        expect(winner_end).to be > winner_start
        expect(loser_end).to be < loser_start
      end
    end

  end

  context 'new (inserted) record' do
    let(:event) { JSON.parse(File.read('./spec/mocks/stream/game-insert.json')) }
    let(:game_stream) { GameStream.new(Aws::DynamoDBStreams::AttributeTranslator
                                         .from_event(event).first)
    }

    it 'parses as inserted' do
      expect(game_stream.ddb_insert?).to eq true
    end

    it 'has a uuid' do
      expect(game_stream.uuid).to match UUID_REGEX
    end

    it 'has an event id' do
      expect(game_stream.event_id).to match /[a-f0-9]{16}/
    end

    it 'converts to json' do
      expect(JSON.parse(game_stream.to_json).class).to be Hash
    end
  end
  context 'aborted' do
    let(:event) { JSON.parse(File.read('spec/mocks/stream/game-modify-with-abort.json')) }
    let(:game_stream) { GameStream.new(Aws::DynamoDBStreams::AttributeTranslator
                                         .from_event(event).first)
    }
    it 'parses as an aborted game' do
      expect(game_stream.game_aborted?).to eq true
    end
    it 'as players to clear cache for' do
      expect(game_stream.player_uuids.size).to eq 2
    end
  end
  context 'added task ip' do
    let(:event) { JSON.parse(File.read('spec/mocks/stream/updated-task-ip.json')) }
    let(:game_stream) { GameStream.new(Aws::DynamoDBStreams::AttributeTranslator
                                         .from_event(event).first)
    }
    it 'parses as a task_ip update event' do
      expect(game_stream.ddb_task_ip_modify?).to eq true
    end
  end
  context 'finished game' do
    let(:event) { JSON.parse(File.read('spec/mocks/stream/game-red-wins-2x2.json')) }
    let(:game_stream) { GameStream.new(Aws::DynamoDBStreams::AttributeTranslator
                                         .from_event(event).first)
    }

    it 'parses as modified' do
      expect(game_stream.ddb_insert?).to eq false
    end

    it 'has a score' do
      expect(game_stream.game_ended_with_score?).to eq true
    end
  end
  context 'zero-zero tie' do
    let(:event) { JSON.parse(File.read('spec/mocks/stream/zero-zero-tie-for-real-1x1.json')) }
    let(:game_stream) { GameStream.new(Aws::DynamoDBStreams::AttributeTranslator
                                         .from_event(event).first)
    }
    it 'has integers not BigDecimals' do
      game_stream.compute_elo_changes
      expect(game_stream.batch.map {|p| p.get_start_elo_for_winner}
               .uniq
               .first)
        .to be_a Integer
    end
  end
end
