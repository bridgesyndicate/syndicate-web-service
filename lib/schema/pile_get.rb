class PileGetSchema
  def self.schema
    {
      type: :object,
      required: [:pile],
      properties: {
        pile: {
          type: :object,
          required: [:isbn, :pile_uuid, :username],
          properties: {
            pile_uuid: {
              type: :uuid
            },
            username: {
              type: :string
            },
            isbn: {
              type: :array,
              items: {
                type: :string,
                pattern: "[0-9a]"
              }
            }
          }
        }
      }
    }
  end
end
