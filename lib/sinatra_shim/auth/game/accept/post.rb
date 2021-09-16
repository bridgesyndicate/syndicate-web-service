module AuthGameAcceptPost
  def auth_game_accept_post(event)
    lamda_result = auth_game_accept_post_handler(event: event, context: '')
    [
      lamda_result[:statusCode],
      lamda_result[:headers],
      lamda_result[:body]
    ]
  end
end

