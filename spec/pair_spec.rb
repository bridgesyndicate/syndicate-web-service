load 'spec_helper.rb'
require 'json-schema'
require 'lib/helpers'
require 'lib/pair'
require 'lib/player'
require 'lib/schema/pair_player_array'

RSpec.describe '#pair' do
  it 'serializes the pair' do
    batch = []
    winner = Player.new(SecureRandom.uuid,
                        Faker::Internet.username,
                        SecureRandom.random_number(10 ** 24),
                        Faker::Internet.username,
                        SecureRandom.random_number(10 ** 3)
                       )
    loser = Player.new(SecureRandom.uuid,
                        Faker::Internet.username,
                        SecureRandom.random_number(10 ** 24),
                        Faker::Internet.username,
                        SecureRandom.random_number(10 ** 3)
                       )
    batch.push(Pair.new(winner, loser))
    winner = Player.new(SecureRandom.uuid,
                        Faker::Internet.username,
                        SecureRandom.random_number(10 ** 24),
                        Faker::Internet.username,
                        SecureRandom.random_number(10 ** 3)
                       )
    loser = Player.new(SecureRandom.uuid,
                        Faker::Internet.username,
                        SecureRandom.random_number(10 ** 24),
                        Faker::Internet.username,
                        SecureRandom.random_number(10 ** 3)
                       )
    batch.push(Pair.new(winner, loser))
    json = batch.to_json
    expect(JSON::Validator
             .validate(PairPlayerArraySchema.schema, json, :strict => true))
      .to equal true
  end
end
