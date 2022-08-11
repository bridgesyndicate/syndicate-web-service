class UserByDiscordIdResponse
  def self.schema
    {
      type: :object,
      patternProperties: {
        "[0-9]": {
          type: :object,
          required: [:elo],
          properties: {
            season_elos: {
              type: :object,
              patternProperties: {
                "^[a-z0-9]+$": {
                  type: :number
                }
              },
              additionalProperties: false
            }
          }
        }
      }
    }
  end
end
