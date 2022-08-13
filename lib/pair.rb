class Pair
  attr_accessor :winner, :loser, :tie, :season

  def initialize(winner, loser, season)
    @winner = winner
    @loser = loser
    @season = season
  end

  def get_start_elo_for_player(player)
    if season
      player.start_elo.season
    else
      player.start_elo.get
    end
  end

  def get_start_elo_for_winner
    get_start_elo_for_player(winner)
  end

  def get_start_elo_for_loser
    get_start_elo_for_player(loser)
  end

  def set_tie
    # make the loser the one with the most start elo
    if get_start_elo_for_player(winner) > get_start_elo_for_player(loser)
      temp = winner # swap winner and loser
      @winner = loser
      @loser = temp
    end
    @tie = true
  end

  def update_elo(winner_end_elo, loser_end_elo)
    unless tie
      winner.end_elo = winner_end_elo
      loser.end_elo = loser_end_elo
    else # for tie, the elo is overloaded with the delta elo
      winner.end_elo = get_start_elo_for_player(winner) + winner_end_elo
      loser.end_elo = get_start_elo_for_player(loser) + loser_end_elo
    end
  end

  def to_json(*args)
    {
      class: self.class.to_s,
      winner: winner.instance_variables.
        to_h { |k| [k.to_s.gsub('@',''), winner.instance_variable_get(k)] },
      loser: loser.instance_variables.
        to_h { |k| [k.to_s.gsub('@',''), loser.instance_variable_get(k)] },
    }.to_json
  end
end
