load 'spec_helper.rb'
require 'lib/helpers'
require 'lib/game_stream'

describe 'GameStream' do
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
      expect(game_stream.batch.map {|p| p.winner.start_elo.class}
               .uniq
               .first)
        .to eq Integer
    end
  end
end
