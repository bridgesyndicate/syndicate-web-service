class Game
  attr_accessor :game, :winner, :uuid

  def initialize game
    @game = game
    @winner = winner
    @uuid = game['uuid']
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
