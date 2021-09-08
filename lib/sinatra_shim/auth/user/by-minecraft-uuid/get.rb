module AuthUserByMinecraftUuidGet
  def auth_user_by_minecraft_uuid_get(event)
    lamda_result = auth_user_by_minecraft_uuid_get_handler(event: event, context: '')
    [
      lamda_result[:statusCode],
      lamda_result[:headers],
      lamda_result[:body]
    ]
  end
end

