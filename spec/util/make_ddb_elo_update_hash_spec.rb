load 'spec_helper.rb'
require 'lib/helpers'
require 'lib/game_stream'
require 'lib/util/make_ddb_elo_update_hash'

describe 'MakeDdbEloUpdateHash' do
  let(:game_stream) { GameStream.new(Aws::DynamoDBStreams::AttributeTranslator
                                       .from_event(event).first)
  }

  before(:each) {
    game_stream.compute_elo_changes
  }

  context 'non-season game' do
    let(:event) { JSON.parse(File.read('spec/mocks/stream/make_ddb_elo_update_hash/non-season-game.json')) }

    it 'makes the update hash' do
      MakeDdbEloUpdateHash.new(game_stream.batch).hash.each do |k, v|
        [:end_elo, :start_elo].each do |s|
          expect(v[s]).to be_a Integer
        end
        expect(v.keys.include?(:start_season_elo)).to be false 
        expect(v.keys.include?(:end_season_elo)).to be false 
        expect(v.keys.include?(:season)).to be false 
      end
    end
  end

  context 'season game' do
    let(:event) { JSON.parse(File.read('spec/mocks/stream/make_ddb_elo_update_hash/season-game.json')) }

    it 'makes the update hash' do
      MakeDdbEloUpdateHash.new(game_stream.batch).hash.each do |k, v|
        [:end_elo, :start_elo, :start_season_elo, :end_season_elo].each do |s|
          expect(v[s]).to be_a Integer
        end
        expect(v[:season]).to be_a String
      end
    end
  end
end
