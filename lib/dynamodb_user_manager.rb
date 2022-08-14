require 'util/make_ddb_elo_update_hash'
require 'time'
require 'aws-sdk-dynamodb'

class DynamodbUserManager
  attr_accessor :client, :table_name, :secondary_index_name

  def initialize()
    @table_name = "syndicate_#{SYNDICATE_ENV}_users"
    @secondary_index_name = 'discord-id-index'
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
    create_table_impl unless @client.list_tables.table_names.include?(table_name)
  end

  def create_table_impl
    schema = {
      key_schema: [
        {
          attribute_name: 'minecraft_uuid',
          key_type: 'HASH'
        }
      ],
      attribute_definitions: [
        {
          attribute_name: 'minecraft_uuid',
          attribute_type: 'S'
        },
        {
          attribute_name: 'discord_id',
          attribute_type: 'S' # I wanted to use 'N', but dynamodb-admin truncates
        }
      ],
      global_secondary_indexes: [
        index_name: secondary_index_name,
        key_schema: [
          {
            attribute_name: "discord_id",
            key_type: "HASH"
          }
        ],
        projection: {
          projection_type: 'ALL'
        },
        provisioned_throughput: {
          read_capacity_units: 1,
          write_capacity_units: 1
        }
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
    @client.create_table(schema.merge({ table_name: table_name }))
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
        table_name: table_name,
        item: item
      }
    )
    item
  end

  def get(minecraft_uuid) ##uid is a reserved word
    client.query(
      {
        table_name: table_name,
        key_condition_expression: "minecraft_uuid = :minecraft_uuid",
        expression_attribute_values: {
          ":minecraft_uuid" => minecraft_uuid
        }
      }
    )
  end

  def ensure_verified(discord_ids)
    # use batch get instead
    discord_ids.map do |id|
      client.query(
        {
          table_name: table_name,
          index_name: secondary_index_name,
          key_condition_expression: "discord_id = :discord_id",
          expression_attribute_values: {
            ":discord_id" => id
          }
        })
    end
  end

  def get_by_discord_id(discord_id)
    client.query(
      {
        table_name: table_name,
        index_name: secondary_index_name,
        key_condition_expression: "discord_id = :discord_id",
        expression_attribute_values: {
          ":discord_id" => discord_id
        }
      })
  end

  def update_elo(minecraft_uuid, elo)
    client.update_item(
      {
        table_name: table_name,
        key: {
          minecraft_uuid: minecraft_uuid
        },
        update_expression: 'SET #updated_at = :now, #elo = :elo',
        expression_attribute_names: {
          '#updated_at': 'updated_at',
          '#elo': 'elo',
        },
        expression_attribute_values: {
          ':now': Time.now.utc.iso8601,
          ':elo': elo
        },
        return_values: 'ALL_NEW'
      }
    )
  end

  def batch_update(batch)
    map = MakeDdbEloUpdateHash.new(batch).hash
    map.each do |k, v|
      binding.pry;1
      update_elo(k, v)
    end
  end

  def get_elo_from_response(response)
    ret = { elo: STARTING_ELO }
    item = response.items.first
    ret = { elo: item['elo'] } if item['elo']
    ret.merge!({ season_elos: item['season_elos'] }) if item['season_elos']
    return ret
  end

  # BatchGetItem can only read from the base table, and not from
  # indexes (LSI, GSI). Therefore, you need to perform several query operations
  # in parallel on your GSI to achieve a similar effect.
  def batch_get_by_discord_ids(users)
    users.map do |user|
      response = get_by_discord_id(user)
      if response.items.size != 0
        discord_id = response.items.first['discord_id']
        elo = get_elo_from_response(response)
        ret = { discord_id => elo }
      end
    end.reduce(Hash.new, :merge)
  end
end
