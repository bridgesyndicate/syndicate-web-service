class BanSchema
  def self.schema
    {
      type: :object,
      required: %w/minecraft_uuid/,
      properties: {
        minecraft_uuid: {
          type: :uuid
        }
      }
    }
  end
end
