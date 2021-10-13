class Pair
  attr_accessor :winner, :loser, :tie

  def initialize(winner, loser)
    @winner = winner
    @loser = loser
  end

  def update_elo(winner_end_elo, loser_end_elo)
    unless tie
      winner.end_elo = winner_end_elo
      loser.end_elo = loser_end_elo
    else
      winner.end_elo = winner.start_elo
      loser.end_elo = loser.start_elo
    end
  end
end
