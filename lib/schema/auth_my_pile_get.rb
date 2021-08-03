class AuthMyPileGetSchema
  def self.schema
    {
      type: :object,
      required: [:user_pile],
      properties: {
        user_pile: {
          type: :object,
          required: %w/username updated_at created_at pile_uuid_list/,
          properties: {
            pile_uuid_list: {
              type: :arry,
              items: {
                type: :uuid
              }
            },
            username: {
              type: :string
            },
            created_at: {
              'type' => 'date-time'
            },
            updated_at: {
              'type' => 'date-time'
            }
          }
        }
      }
    }
  end
end
