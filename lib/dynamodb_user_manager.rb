require 'time'
require 'aws-sdk-dynamodb'

class DynamodbUserManager
  attr_accessor :client, :table_name

  def initialize()
    @table_name = "syndicate_#{SYNDICATE_ENV}_users"
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
                   { attribute_name: 'minecraft_uuid',  key_type: 'HASH' }
                  ],
      attribute_definitions: [
                              { attribute_name: 'minecraft_uuid',    attribute_type: 'S' }
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

  def put(minecraft_uuid, discord_id, kick_code, kick_code_created_at)
    item = {
      'updated_at' => Time.now.utc.iso8601,
      'created_at' => Time.now.utc.iso8601,
      'minecraft_uuid' => minecraft_uuid,
      'discord_id' => discord_id,
      'kick_code' => kick_code,
      'kick_code_created_at' => kick_code_created_at
    }
    @client.put_item(
      {
        table_name: @table_name,
        item: item
      }
    )
    item
  end

  def get(minecraft_uuid) ##uid is a reserved word
    client.query(
      {
        table_name: @table_name,
        key_condition_expression: "minecraft_uuid = :minecraft_uuid",
        expression_attribute_values: {
          ":minecraft_uuid" => minecraft_uuid
        }
      }
    )
  end
end
