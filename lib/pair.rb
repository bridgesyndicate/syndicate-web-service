class Pair
  attr_accessor :winner, :loser, :tie

  def initialize(winner, loser)
    @winner = winner
    @loser = loser
  end

  def set_tie
    # make the loser the one with the most start elo
    if winner.start_elo > loser.start_elo
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
      winner.end_elo = winner.start_elo + winner_end_elo
      loser.end_elo = loser.start_elo + loser_end_elo
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
