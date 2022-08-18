class MakeDdbEloUpdateHash
  attr_accessor :batch, :hash

  def initialize(batch)
    @batch = batch
    @hash = Hash.new
    make_hash
  end

  def make_hash
    batch.each do |pair|
      unless pair.season.blank?
        k, v = make_hash_from(player: pair.winner, season: pair.season)
        hash.has_key?(k) ? hash[k].merge!(v) : hash[k] = v
        k, v = make_hash_from(player: pair.loser, season: pair.season)
        hash.has_key?(k) ? hash[k].merge!(v) : hash[k] = v
      else
        k, v = make_hash_from(player: pair.winner)
        hash.has_key?(k) ? hash[k].merge!(v) : hash[k] = v
        k, v = make_hash_from(player: pair.loser)
        hash.has_key?(k) ? hash[k].merge!(v) : hash[k] = v
      end
    end
  end

  def make_hash_from(player:, season: '')
    unless season.blank?
      v = { start_season_elo: player.start_elo.season,
        end_season_elo: player.end_elo,
        season: season }
    else
      v = { start_elo: player.start_elo.get,
        end_elo: player.end_elo
      }
    end
    [player.minecraft_uuid, v]
  end
end
