class GamePostSchema
  def self.schema
    {
      type: :object,
      required: %w/blueTeam redTeam requiredPlayers goalsToWin gameLengthInSeconds/,
      properties: {
        goalsToWin: {
          type: :integer,
          minimum: 1,
          maximum: 5
        },
        gameLengthInSeconds: {
          type: :integer,
          minimum: 60,
          maximum: 1800
        },
        requiredPlayers: {
          type: :integer,
          minimum: 0,
          maximum: 8
        },
        redTeam: {
          type: :array,
          items: {
            type: :string
          }
        },
        blueTeam: {
          type: :array,
          items: {
            type: :string
          }
        }
      }
    }
  end
end
