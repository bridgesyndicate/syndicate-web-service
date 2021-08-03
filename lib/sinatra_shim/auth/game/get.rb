module AuthPileGet
  def auth_pile_get(event)
    lamda_result = auth_pile_handler(event: event, context: '')
    [
      lamda_result[:statusCode],
      lamda_result[:headers],
      lamda_result[:body]
    ]
  end
end

