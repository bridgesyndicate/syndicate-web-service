class Player
  attr_accessor :minecraft_uuid, :discord_id, :start_elo, :end_elo,
                :minecraft_name, :discord_name, :class

  def initialize(minecraft_uuid, minecraft_name,
                 discord_id, discord_name,
                 start_elo)
    @minecraft_uuid = minecraft_uuid
    @minecraft_name = minecraft_name
    @discord_name = discord_name
    @discord_id = discord_id
    @start_elo = start_elo
    @class = Player.to_s
  end

end
