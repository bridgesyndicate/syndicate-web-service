require 'pair'
require 'player'

class Game
  attr_accessor :game, :winner, :uuid, :red, :blue

  def initialize game
    @game = game
    @winner = winner
    @uuid = game['uuid']
    @red = make_team('red')
    @blue = make_team('blue')
  end

  def make_team(color)
    game["#{color}_team_minecraft_uuids"].map.with_index do |uuid, i|
      Player.new(
        uuid,
        game['player_map'].key(uuid),
        game["#{color}_team_discord_ids"][i],
        game["#{color}_team_discord_names"][i],
        BigDecimal(game["elo_before_game"][game["#{color}_team_discord_ids"][i]]).to_i
      )
    end
  end

  def red_by_elo
    red.sort {|a,b| a.start_elo <=> b.start_elo }
  end

  def blue_by_elo
    blue.sort {|a,b| a.start_elo <=> b.start_elo }
  end

  def get_elo_matched_winning_pairs
    red_by_elo.map.with_index do |r, i|
      args = (winner) ? [r, blue_by_elo[i]] : [blue_by_elo[i], r]
      Pair.new(*args)
    end
  end

  def winner
    score = game['game_score']
    score['red'] = BigDecimal(score['red']).to_i
    score['blue'] = BigDecimal(score['blue']).to_i
    diff = score['red'] - score['blue']
    if diff > 0
      1
    elsif diff < 0
      -1
    else
      0
    end
  end

  def profiles_from_ids(ids)
    ids.map do |id|
      "<@#{id}>"
    end.join(', ')
  end

  def winner_score
    (winner == -1) ? game.game_score.blue : game.game_score.red
  end

  def loser_score
    (winner == -1) ? game.game_score.red : game.game_score.blue
  end

  def winner_names
    (winner == -1) ? profiles_from_ids(game.blue_team_discord_ids) : profiles_from_ids(game.red_team_discord_ids)
  end

  def loser_names
    (winner == -1) ? profiles_from_ids(game.red_team_discord_ids) : profiles_from_ids(game.blue_team_discord_ids)
  end

  def comparison_word
    (winner == 0 ) ? 'ties' : 'defeats'
  end

  def description
    "#{winner_names} (#{winner_score}) #{comparison_word} " +
      "#{loser_names} (#{loser_score})"
  end
end
