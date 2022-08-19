class Elos
  attr_accessor :get, :season

  def initialize (elo, season)
    @get = elo
    @season = season
  end

  def as_json(**args)
    {
      elo: get,
      season: season
    }
  end
end
