module AuthRegisterByKickCodePost
  def auth_register_by_kick_code_post(event)
    lamda_result = auth_register_by_kick_code_post_handler(event: event, context: '')
    [
      lamda_result[:statusCode],
      lamda_result[:headers],
      lamda_result[:body]
    ]
  end
end

