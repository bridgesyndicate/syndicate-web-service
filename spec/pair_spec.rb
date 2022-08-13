load 'spec_helper.rb'
require 'json-schema'
require 'lib/helpers'
require 'lib/pair'
require 'lib/player'
require 'lib/schema/pair_player_array'

def get_random_player
  Player.new(SecureRandom.uuid,
             Faker::Internet.username,
             SecureRandom.random_number(10 ** 24),
             Faker::Internet.username,
             SecureRandom.random_number(10 ** 3)
             )
end

RSpec.describe '#pair' do
  it 'serializes the pair' do
    batch = []
    2.times do
      winner = get_random_player
      loser = get_random_player
      batch.push(Pair.new(winner, loser, false))
    end
    json = batch.to_json
    expect(JSON::Validator
             .validate(PairPlayerArraySchema.schema, json, :strict => true))
      .to equal true
  end
end
