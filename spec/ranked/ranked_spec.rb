load 'spec_helper.rb'
require 'ranked'
require 'pry'

RSpec.describe '#ranked' do
  context 'basic match making' do
    let (:queue) { Ranked::Queue.new }
    let (:now) { Time.now.to_i }
    let (:p1)  { Ranked::Player.new(discord_id: rand(100), # Install Factory Girl?
                                    discord_username: 'harry',
                                    queue_time: now,
                                    elo: 600)
    }
    let (:p2) { Ranked::Player.new(discord_id: rand(100),
                                   discord_username: 'ken',
                                   queue_time: now + 10)
    }
    let (:p3) { Ranked::Player.new(discord_id: rand(100),
                                   discord_username: 'joe',
                                   queue_time: now + 20,
                                   elo: 750
                                  )
    }

    describe 'with one player queued' do
      it 'keeps the player queued' do
        queue.queue_player(p1)
        expect(queue.process_queue).to eq nil
        expect(queue.queue.size).to eq 1
      end
    end
    describe 'with two players who are not elo-matchable queued' do
      it 'keeps the player queued' do
        queue.queue_player(p1)
        queue.queue_player(p2)
        expect(queue.process_queue).to eq nil
        expect(queue.queue.size).to eq 2
      end
    end
    describe 'with three players queued, two are elo-matchable' do
      it 'makes a match' do
        queue.queue_player(p1)
        queue.queue_player(p2)
        queue.queue_player(p3)
        expect(queue.process_queue.class).to eq Ranked::Match
        expect(queue.queue.size).to eq 2
      end
    end
  end
end

# #EloRating::k_factor = 10
# match = EloRating::Match.new
# match.add_player(rating: q1.elo)
# match.add_player(rating: q2.elo, winner: true)
# puts match.updated_ratings
