class PurchasePostSchema
  def self.schema
    purchase_post_schema = {
  "type" => "object",
  "required" => ["purchase"],
  "properties" => {
    "purchase" => {
      "type" => "object",
      "required" => ["customer_uuid", "vendor_uuid", "isbn", "price",
                     "delivery_promise"],
      "properties" => {
        "customer_uuid" => {
          "type" => "uuid"
        },
        "vendor_uuid" => {
          "type" => "uuid"
        },
        "isbn" => {
          "type" => "string",
          "pattern": "[0-9]"
        },
        "price" => {
          "type" => "number"
        },
        "delivery_promise" => {
          "type" => "string"
        },
      }
    }
  }
}
  end
end
