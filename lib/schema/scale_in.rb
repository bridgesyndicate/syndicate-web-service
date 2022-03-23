class ScaleInSchema
  def self.schema
    {
      type: :object,
      required: %w/task_arn/,
      properties: {
        task_arn: {
          type: :string
        }
      }
    }
  end
end
