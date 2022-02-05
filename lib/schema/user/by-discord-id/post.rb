class UserByDiscordIdPost
  def self.schema
    {
      type: :array,
      items: {
        type: :string,
        pattern: '[0-9]'
      }
    }
  end
end
