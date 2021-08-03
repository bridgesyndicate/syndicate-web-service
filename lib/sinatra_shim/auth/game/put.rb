module AuthPilePut
  def auth_pile_put(event)
    lamda_result = auth_pile_put_handler(event: event, context: '')
    [
      lamda_result[:statusCode],
      lamda_result[:headers],
      lamda_result[:body]
    ]
  end
end

