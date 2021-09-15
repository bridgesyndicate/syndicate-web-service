class GamePostSchema
  def self.schema
    {
      type: :object,
      required: %w/uuid blue_team_discord_ids blue_team_discord_names
                   red_team_discord_ids red_team_discord_names required_players
                   goals_to_win game_length_in_seconds queued_at queued_via/,
      properties: {
        uuid: {
          type: :uuid
        },
        blue_team_discord_ids: {
          type: :array,
          items: {
            type: :integer
          }
        },
        blue_team_discord_names: {
          type: :array,
          items: {
            type: :string
          }
        },
        red_team_discord_ids: {
          type: :array,
          items: {
            type: :integer
          }
        },
        red_team_discord_names: {
          type: :array,
          items: {
            type: :string
          }
        },
        accepted_by_discord_ids: {
          type: :array,
          items: {
            type: :integer
          }
        },
        goals_to_win: {
          type: :integer,
          minimum: 1,
          maximum: 5
        },
        game_length_in_seconds: {
          type: :integer,
          minimum: 60,
          maximum: 1800
        },
        required_players: {
          type: :integer,
          minimum: 0,
          maximum: 8
        },
        queued_at: {
          type: :integer,
        },
        queued_via: {
          type: :string
        }
      }
    }
  end
end
