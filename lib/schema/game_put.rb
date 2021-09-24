class GamePutSchema
  def self.schema
    {
      type: :object,
      required: %w/uuid red_team_minecraft_uuids blue_team_minecraft_uuids
                   blue_team_discord_ids blue_team_discord_names
                   red_team_discord_ids red_team_discord_names required_players
                   goals_to_win game_length_in_seconds queued_at queued_via/,
      properties: {
        red_team_minecraft_uuids: {
          type: :array,
          items: {
            type: :uuid
          }
        },
        blue_team_minecraft_uuids: {
          type: :array,
          items: {
            type: :uuid
          }
        },
        blue_team_discord_ids: {
          type: :array,
          items: {
            type: :string
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
            type: :string
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
            type: :object,
            required: %w/discord_id accepted_at/,
            properties: {
              discord_id: {
                type: :string
              },
              accepted_at: {
                type: :"date-time",
              }
            }
          }
        },
        goals_to_win: {
          type: :integer,
          minimum: 1,
          maximum: 5
        },
        game_length_in_seconds: {
          type: :integer,
          minimum: 30,
          maximum: 1800
        },
        required_players: {
          type: :integer,
          minimum: 0,
          maximum: 8
        },
        remaining_time_formatted: {
          type: :string,
        },
        remaining_time_in_seconds: {
          type: :integer
        },
        number_of_joined_players: {
          type: :integer
        },
        game_started_at: {
          type: :integer
        },
        game_ended_at: {
          type: :integer
        },
        state: {
          type: :string
        },
        task_ip: {
          type: :string
        },
        uuid: {
          type: :uuid
        },
        kills_registered: {
          type: :array,
          items: {
            player_UUID: {
              type: :string
            },
            kill_time: {
              type: :integer
            }
          }
        },
        player_map: {
          type: :object,
        },
        game_score: {
          items: {
            red: {
              type: :integer,
            },
            blue: {
              type: :integer,
            }
          }
        },
        joined_players: {
          type: :array,
          items: :string
        },
        goals_scored: {
          type: :array,
          items: {
            player_UUID: {
              type: :string
            },
            goal_time: {
              type: :integer
            }
          }
        },
        final_game_length_formatted: {
          type: :string
        },
        queued_via: {
          type: :string
        },
        queued_at: {
          type: :"date-time"
        },
        dequeued_at: {
          type: :"date-time"
        }
      }
    }
  end
end
