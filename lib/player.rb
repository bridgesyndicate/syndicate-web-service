class Player
  attr_accessor :minecraft_uuid, :discord_id, :start_elo, :end_elo,
                :minecraft_name, :discord_name, :klass

  def initialize(minecraft_uuid, minecraft_name,
                 discord_id, discord_name,
                 start_elo)
    @minecraft_uuid = minecraft_uuid
    @minecraft_name = minecraft_name
    @discord_name = discord_name
    @discord_id = discord_id
    @start_elo = start_elo
    @klass = Player.to_s
  end

  def as_json(*args)
    {
      minecraft_uuid: minecraft_uuid,
      minecraft_name: minecraft_name,
      discord_name: discord_name,
      discord_id: discord_id,
      start_elo: start_elo.as_json,
      end_elo: end_elo
    }.merge({:class => klass})
  end
end
