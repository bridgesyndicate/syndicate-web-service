require 'lib/pair'
require 'lib/player'
require 'lib/elos'

class Game

  attr_accessor :game, :winner, :uuid, :red, :blue, :season

  def initialize game
    @game = JSON.parse(game.to_json) # gets rid of BigDecimals
    @season = game['season'] ? game['season'] : nil
    @winner = winner
    @uuid = game['uuid']
    @red = make_team('red')
    @blue = make_team('blue')
  end

  def elo_for_player(player)
    elo_hash = game["elo_before_game"][player]
    if elo_hash["season_elos"].nil? || elo_hash["season_elos"][season].nil?
      season_elo = STARTING_ELO
    else
      season_elo = elo_hash["season_elos"][season]
    end
    Elos.new(elo_hash["elo"], season.nil? ? nil : season_elo)
  end

  def make_team(color)
    game["#{color}_team_minecraft_uuids"].map.with_index do |uuid, i|
      Player.new(
                 uuid,
                 game['player_map'].key(uuid),
                 game["#{color}_team_discord_ids"][i],
                 game["#{color}_team_discord_names"][i],
                 elo_for_player(game["#{color}_team_discord_ids"][i])
                 )
    end
  end

  def red_by_elo(by_season)
    if by_season
      red.sort {|a,b| a.start_elo.season <=> b.start_elo.season }
    else
      red.sort {|a,b| a.start_elo.get <=> b.start_elo.get }
    end
  end

  def blue_by_elo(by_season)
    if by_season
      blue.sort {|a,b| a.start_elo.season <=> b.start_elo.season }
    else
      blue.sort {|a,b| a.start_elo.get <=> b.start_elo.get }
    end
  end

  def get_elo_matched_winning_pairs(season)
    red_by_elo(season).map.with_index do |r, i|
      if winner == 1
        playerA = r
        playerB = blue_by_elo(season)[i]
      else
        playerA = blue_by_elo(season)[i]
        playerB = r
      end
      pair = Pair.new(playerA.clone, playerB.clone, season)
      pair.set_tie if winner == 0
      pair
    end
  end

  def winner
    score = game['game_score']
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
