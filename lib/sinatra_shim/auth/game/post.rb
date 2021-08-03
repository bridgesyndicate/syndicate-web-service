module AuthGamePost
  def auth_game_post(event)
    lamda_result = game_post_handler(event: event, context: '')
    [
      lamda_result[:statusCode],
      lamda_result[:headers],
      lamda_result[:body]
    ]
  end
end

