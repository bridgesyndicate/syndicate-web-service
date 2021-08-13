class GamePutSchema
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
        },
        remainingTimeFormatted: {
          type: :string,
        },
        remainingTimeInSeconds: {
          type: :integer
        },
        numberOfJoinedPlayers: {
          type: :integer
        },
        gameStartedAt: {
          type: :integer
        },
        gameEndedAt: {
          type: :integer
        },
        state: {
          type: :string
        },
        taskArn: {
          type: :string
        },
        uuid: {
          type: :uuid
        },
        killsRegistered: {
          type: :array,
          items: {
            playerUUID: {
              type: :string
            },
            killTime: {
              type: :integer
            }
          }
        },
        playerMap: {
          type: :object,
        },
        gameScore: {
          items: {
            red: {
              type: :integer,
            },
            blue: {
              type: :integer,
            }
          }
        },
        joinedPlayers: {
          type: :array,
          items: :string
        },
        goalsScored: {
          type: :array,
          items: {
            playerUUID: {
              type: :string
            },
            goalTime: {
              type: :integer
            }
          }
        },
        finalGameLengthFormatted: {
          type: :string
        },
        queuedAt: {
          type: :integer,
        },
        dequeuedAt: {
          type: :integer,
        }
      }
    }
  end
end
