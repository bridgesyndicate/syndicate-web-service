class GameContainerMetadataSchema
  def self.schema
    {
      type: :object,
      required: %w/uuid taskArn/,
      properties: {
        uuid: {
          type: :uuid,
        },
        taskArn: {
          type: :string
        }
      }
    }
  end
end
