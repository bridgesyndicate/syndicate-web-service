require 'time'
require 'aws-sdk-dynamodb'
require 'lib/object_not_found'

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
      table_name: table_name
    }

    provisioned_capacity = {
      provisioned_throughput: {
        read_capacity_units: 1,
        write_capacity_units: 1
      }
    }

    schema = schema.merge(provisioned_capacity)
    puts schema.inspect
    client.create_table(schema.merge({ table_name: table_name }))
  end

  def update_task_ip(game_uuid, task_ip)
    puts "(begin) update_task_ip(#{game_uuid}, #{task_ip})"
    begin
      client.update_item(
        table_name: table_name,
        key: { "game_uuid": game_uuid },
        update_expression: 'SET game.task_ip=:pVal',
        expression_attribute_values: { ':pVal' => task_ip },
        condition_expression: 'attribute_exists(game_uuid)',
        return_values: 'ALL_NEW'
      )
    rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
      ObjectNotFound
    end
  end

  def update_game(game_uuid, game)
    begin
      client.update_item(
        table_name: table_name,
        key: { "game_uuid": game_uuid },
        update_expression: 'SET game=:pVal',
        expression_attribute_values: { ':pVal' => game },
        condition_expression: 'attribute_exists(game_uuid)',
        return_values: 'UPDATED_NEW'
      )
    rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
      ObjectNotFound
    end
  end

  def put(p)
    client.put_item(
      {
        table_name: table_name,
        item: {
          'game_uuid' => p.uuid,
          'created_at' => Time.now.utc.iso8601,
          'updated_at' => Time.now.utc.iso8601,
          'game' => p
        }
      }
    )
  end

  def add_accepted_by_discord_id(game_uuid, discord_id)
    new_acceptance = [
      {
        discord_id: "#{discord_id}",
        accepted_at: Time.now.utc.iso8601
      }
    ]
    params = {
      table_name: table_name,
      key: {
        game_uuid: game_uuid
      },
      update_expression: 'SET #g.#l = list_append(:vals, #g.#l), #updated_at = :now',
      expression_attribute_names: { '#g': 'game',
                                    '#l': 'accepted_by_discord_ids',
                                    '#updated_at': 'updated_at'
                                  },
      expression_attribute_values: { ':vals': new_acceptance,
                                     ':now': Time.now.utc.iso8601
                                   },
      return_values: 'ALL_NEW'
    }
    ret = client.update_item(params)
    ret.attributes['game'].transform_values! do |value|
      value.class == BigDecimal ? value.to_f : value
    end
    ret
  end

  def get(game_uuid)
    client.query(
      {
        table_name: table_name,
        consistent_read: true,
        key_condition_expression: "game_uuid = :game_uuid",
        expression_attribute_values: {
          ":game_uuid" => game_uuid
        }
      }
    )
  end
end
