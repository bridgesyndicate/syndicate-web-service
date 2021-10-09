class Pair
  attr_accessor :winner, :loser

  def initialize(winner, loser)
    @winner = winner
    @loser = loser
  end

  def update_elo(winner_end_elo, loser_end_elo)
    winner.end_elo = winner_end_elo
    loser.end_elo = loser_end_elo
  end
end
