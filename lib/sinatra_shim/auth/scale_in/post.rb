module AuthScaleInPost
  def auth_scale_in_post(event)
    lamda_result = auth_scale_in_post_handler(event: event, context: '')
    [
      lamda_result[:statusCode],
      lamda_result[:headers],
      lamda_result[:body]
    ]
  end
end

