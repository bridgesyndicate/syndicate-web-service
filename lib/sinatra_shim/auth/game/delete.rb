module AuthPileGet
  def auth_pile_delete(event)
    lamda_result = auth_pile_delete_handler(event: event, context: '')
    [
      lamda_result[:statusCode],
      lamda_result[:headers],
      lamda_result[:body]
    ]
  end
end

