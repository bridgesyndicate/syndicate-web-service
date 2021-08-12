module AuthGamePut
  def auth_game_put(event)
    lamda_result = auth_game_put_handler(event: event, context: '')
    [
      lamda_result[:statusCode],
      lamda_result[:headers],
      lamda_result[:body]
    ]
  end
end

