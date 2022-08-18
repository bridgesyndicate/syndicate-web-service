load 'spec_helper.rb'
require 'json-schema'
require 'lib/helpers'
require 'lib/pair'
require 'lib/player'
require 'lib/elos'
require 'lib/schema/pair_player_array'

def get_random_player(season: nil)
  Player.new(SecureRandom.uuid,
             Faker::Internet.username,
             SecureRandom.random_number(10 ** 24),
             Faker::Internet.username,
             Elos.new(SecureRandom.random_number(10 ** 3),
                      season.nil? ? nil : season
                     )
            )
end

RSpec.describe '#pair' do
  it 'serializes a pair without season' do
    batch = []
    2.times do
      winner = get_random_player
      loser = get_random_player
      batch.push(Pair.new(winner, loser, nil))
    end
    batch[0].update_elo(100,100)
    batch[1].update_elo(200,200)
    json = batch.to_json
    expect(JSON::Validator
             .validate(PairPlayerArraySchema.schema, json))
      .to equal true
  end

  it 'serializes a pair with season' do
    batch = []
    2.times do
      season = random_string
      winner = get_random_player(season: season)
      loser = get_random_player(season: season)
      batch.push(Pair.new(winner, loser, season))
    end
    batch[0].update_elo(100,100)
    batch[1].update_elo(200,200)
    json = batch.to_json
    expect(JSON::Validator
             .validate(PairPlayerArraySchema.schema, json))
      .to equal true
  end
end
