module AuthWarp
  def auth_warp_post(event)
    lamda_result = auth_warp_post_handler(event: event, context: '')
    [
      lamda_result[:statusCode],
      lamda_result[:headers],
      lamda_result[:body]
    ]
  end
end

