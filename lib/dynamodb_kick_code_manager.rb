require 'time'
require 'aws-sdk-dynamodb'

class DynamodbKickCodeManager
  attr_accessor :client, :table_name

  def initialize()
    @table_name = "syndicate_#{SYNDICATE_ENV}_kick_codes"
    options = {
      region: AwsCredentials.instance.region,
      credentials: AwsCredentials.instance.credentials,
    }
    options = options.merge({
                              endpoint: AwsCredentials.instance.endpoint
                            }) unless AwsCredentials.instance.endpoint.nil?
    @client = Aws::DynamoDB::Client.new(options)
  end

  def create_table
    create_table_impl unless @client.list_tables.table_names.include?(@table_name)
  end

  def create_table_impl
    schema = {
      key_schema: [
                   { attribute_name: 'kick_code',  key_type: 'HASH' }
                  ],
      attribute_definitions: [
                              { attribute_name: 'kick_code',    attribute_type: 'S' }
                             ],
      table_name: @table_name
    }

    provisioned_capacity = {
      provisioned_throughput: {
        read_capacity_units: 10,
        write_capacity_units: 5
      }
    }

    schema = schema.merge(provisioned_capacity)
    puts schema.inspect
    @client.create_table(schema.merge({ table_name: @table_name }))
  end

  def put(kick_code, uuid)
    @client.put_item(
      {
        table_name: @table_name,
        item: {
          'created_at' => Time.now.utc.iso8601,
          'kick_code' => kick_code,
          'minecraft_uuid' => uuid
        }
      }
    )
  end

  def get(kick_code)
    client.query(
      {
        table_name: @table_name,
        key_condition_expression: 'kick_code = :kick_code',
        expression_attribute_values: {
          ':kick_code' => kick_code
        }
      }
    )
  end

  class ObjectNotFound
  end
end
