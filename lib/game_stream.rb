require 'lib/game'
require 'lib/postgres_client'

class GameStream
  attr_accessor :game_hash, :batch

  def initialize(record)
    @game_hash = record.to_h
  end

  def ddb_insert?
    game_hash[:event_name] == 'INSERT'
  end

  def uuid
    game_hash[:dynamodb][:new_image]["game"]["uuid"]
  end

  def player_uuids
    game_hash[:dynamodb][:new_image]["game"]["red_team_minecraft_uuids"] +
      game_hash[:dynamodb][:new_image]["game"]["blue_team_minecraft_uuids"]
  end

  def ddb_task_ip_modify?
    game_hash[:event_name] == 'MODIFY' and
      !game_ended_with_score? and
      !game_hash[:dynamodb][:new_image]['game']['state'] and # this is a quirk of the way we update, should be "Before_game"
      !!game_hash[:dynamodb][:new_image]['game']['task_ip']
  end

  def event_id
    game_hash[:event_id]
  end

  def to_json
    game_hash.to_json
  end

  def game_ended_with_score?
    game_hash[:event_name] == 'MODIFY' and
      !!game_hash[:dynamodb][:new_image]['game']['game_score'] and
      game_hash[:dynamodb][:new_image]['game']['state'] == 'AFTER_GAME'
  end

  def generate_elo_batch
    game = Game.new(game_hash[:dynamodb][:new_image]['game'])
    pairs = game.get_elo_matched_winning_pairs
    pairs.each do |pair|
      if pair.tie
        adjust = EloRating.rating_adjustment(
          EloRating.expected_score(pair.loser.start_elo,
                                   pair.winner.start_elo), 0)/2
        adjust = adjust.round
        pair.update_elo(-adjust, adjust)
      else
        match = EloRating::Match.new
        match.add_player(rating: pair.winner.start_elo, winner: true)
        match.add_player(rating: pair.loser.start_elo)
        pair.update_elo(*match.updated_ratings)
      end
    end
  end

  def compute_elo_changes
    @batch = generate_elo_batch
    elo_info = batch.to_json
    game_hash[:dynamodb][:new_image]["game"]["elo_info"] = JSON.parse(elo_info)
  end

  def update_leaderboard
    PostgresClient.instance.prepare
    batch.each do |m|
      if m.tie
        res = $pg_conn.exec_prepared('update_tie', [ m.winner.end_elo,
                                                      m.winner.discord_id
        ])
        if res.cmd_tuples == 0
          $pg_conn.exec_prepared('new_tie', [m.winner.discord_id,
                                                       m.winner.minecraft_uuid,
                                                       m.winner.end_elo,
                    ])
        end
        res = $pg_conn.exec_prepared('update_tie', [ m.loser.end_elo,
                                                      m.loser.discord_id
        ])
        if res.cmd_tuples == 0
          $pg_conn.exec_prepared('new_tie', [m.loser.discord_id,
                                                       m.loser.minecraft_uuid,
                                                       m.loser.end_elo,
                    ])
        end
      else
        res = $pg_conn.exec_prepared('update_winner', [ m.winner.end_elo,
                                                         m.winner.discord_id
        ])
        if res.cmd_tuples == 0
          $pg_conn.exec_prepared('new_winner', [m.winner.discord_id,
                                                          m.winner.minecraft_uuid,
                                                          m.winner.end_elo,
                    ])
        end
        resl = $pg_conn.exec_prepared('update_loser', [ m.loser.end_elo,
                                                        m.loser.discord_id
        ])
        if resl.cmd_tuples == 0
          $pg_conn.exec_prepared('new_loser', [m.loser.discord_id,
                                                         m.loser.minecraft_uuid,
                                                         m.loser.end_elo,
                    ])
        end
      end
    end
  end
end
