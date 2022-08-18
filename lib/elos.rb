class Elos
  attr_accessor :get, :season

  def initialize (elo, season)
    @get = elo
    @season = season
  end

  def as_json(**args)
    self.get # not sure what we should return
  end
end
