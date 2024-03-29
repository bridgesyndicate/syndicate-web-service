class PairPlayerArraySchema
  def self.schema
    {
      type: :array,
      items: {
        "$ref": "#/$defs/pair"
      },
      "$defs": {
                 pair: {
                   type: :object,
                   required: %w/class winner loser/,
                   properties: {
                     "class": {
                             type: :string
                           },
                     winner: { "$ref": "#/$defs/player" },
                     loser: { "$ref": "#/$defs/player" }
                   }
                 },
                 elos: {
                   type: :object,
                   required: %w/elo season/,
                   properties: {
                     elo: {
                       type: :number
                     },
                     season: {
                       type: :number
                     }
                   }
                 },
                 player: {
                   type: :object,
                   required: %w/class minecraft_uuid minecraft_name/ +
                   %w/discord_name discord_id start_elo/,
                   properties: {
                     class: {
                       type: :string
                     },
                     discord_id: {
                       type: :number
                     },
                     discord_name: {
                       type: :string
                     },
                     minecraft_uuid: {
                       type: :uuid
                     },
                     minecraft_name: {
                       type: :string
                     },
                     start_elo: {
                       type: :elos
                     },
                     end_elo: {
                       type: :number
                     }
                   }
                 }
               }
    }
  end
end
