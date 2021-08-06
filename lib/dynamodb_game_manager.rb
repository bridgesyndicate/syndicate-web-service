require 'time'
require 'aws-sdk-dynamodb'

class DynamodbGameManager
  attr_accessor :client, :table_name

  def initialize()
    @table_name = "syndicate_#{SYNDICATE_ENV}_games"
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
                   { attribute_name: 'game_uuid',  key_type: 'HASH' }
                  ],
      attribute_definitions: [
                              { attribute_name: 'game_uuid',    attribute_type: 'S' }
                             ],
      table_name: @table_name
    }

    provisioned_capacity = {
      provisioned_throughput: {
        read_capacity_units: 10,
        write_capacity_units: 5
      }
    }
      
    schema = schema.merge(provisioned_capacity) if SYNDICATE_ENV == 'development'      
    puts schema.inspect
    @client.create_table(schema.merge({ table_name: @table_name }))
  end

  def delete(pile_uuid)
    params = {
      table_name: @table_name,
      key: {
        pile_uuid: pile_uuid
      },
      return_consumed_capacity: "INDEXES",
      return_item_collection_metrics: "SIZE"
    }
    client.delete_item(params)
  end

  def put(p)
    @client.put_item(
      {
        table_name: @table_name,
        item: {
          'game_uuid' => p.uuid,
          'created_at' => Time.now.utc.iso8601,
          'game' => p.game_data
        }
      }
    )
  end

  def get(pile_uuid) ##uid is a reserved word
    client.query(
      {
        table_name: @table_name,
        key_condition_expression: "pile_uuid = :pile_uuid",
        expression_attribute_values: {
          ":pile_uuid" => pile_uuid
        }
      }
    )
  end
end
