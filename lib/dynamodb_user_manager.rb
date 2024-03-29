require 'lib/util/make_ddb_elo_update_hash'
require 'time'
require 'aws-sdk-dynamodb'

class DynamodbUserManager
  class NoEloError < StandardError
  end
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

  def now
    Time.now.utc.iso8601
  end

  def add_empty_ban_arrays_for_user(minecraft_uuid)
    begin
    client.update_item({
                         table_name: table_name,
                         key: {
                           minecraft_uuid: minecraft_uuid
                         },
                         update_expression: 'SET #banned_at = :empty_array, #unbanned_at = :empty_array',
                         expression_attribute_names: {
                           '#banned_at': 'banned_at',
                           '#unbanned_at': 'unbanned_at',
                         },
                         expression_attribute_values: {
                           ':empty_array': []
                         },
                         condition_expression: 'attribute_not_exists(banned_at) AND attribute_not_exists(unbanned_at)',
                         return_values: 'ALL_NEW'
                       })
      print '.'
      rescue => e
      print "X"
    end
  end

  def add_blank_season_elo_for_user(minecraft_uuid)
    client.update_item(
      {
        table_name: table_name,
        key: {
          minecraft_uuid: minecraft_uuid
        },
        update_expression: 'SET #season_elos = :empty',
        expression_attribute_names: {
          '#season_elos': 'season_elos'
        },
        expression_attribute_values: {
          ':empty': {}
        },
        return_values: 'ALL_NEW'
      }
    )
  end

  def add_starting_elo_for_user(minecraft_uuid)
    begin
      client.update_item(
        {
          table_name: table_name,
          key: {
            minecraft_uuid: minecraft_uuid
          },
          update_expression: 'SET #elo = :starting_elo',
          expression_attribute_names: {
            '#elo': 'elo'
          },
          expression_attribute_values: {
            ':starting_elo': STARTING_ELO
          },
          condition_expression: 'attribute_not_exists(elo)',
          return_values: 'ALL_NEW'
        }
      )
    rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
      puts "#{minecraft_uuid} already has elo"
    end
  end

  def add_elo
    begin
      ret = client.scan(
        {
          table_name: table_name
        }
      )
      puts ret.count
      ret.items.each do |item|
        puts "doing: #{item['minecraft_uuid']}"
        add_starting_elo_for_user(item['minecraft_uuid'])
        sleep 1
      end
    end while !ret.last_evaluated_key.nil?
  end

  def add_season_elo
    begin
      ret = client.scan(
        {
          table_name: table_name
        }
      )
      puts ret.count
      ret.items.each do |item|
        print '.'
        add_blank_season_elo_for_user(item['minecraft_uuid'])
        sleep 1
      end
    end while !ret.last_evaluated_key.nil?
  end

  def add_ban_and_unban_arrays
    begin
      ret = client.scan(
        {
          table_name: table_name
        }
      )
      puts ret.count
      ret.items.each do |item|
        add_empty_ban_arrays_for_user(item['minecraft_uuid'])
        sleep 1
      end
    end while !ret.last_evaluated_key.nil?
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
      'updated_at' => now,
      'created_at' => now,
      'minecraft_uuid' => minecraft_uuid,
      'discord_id' => discord_id,
      'kick_code' => kick_code,
      'kick_code_created_at' => kick_code_created_at,
      'elo' => STARTING_ELO,
      'season_elos' => {},
      'banned_at' => [],
      'unbanned_at' => []
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

  def update_elo(minecraft_uuid, elo_hash)
    update_hash = {
      table_name: table_name,
      key: {
        minecraft_uuid: minecraft_uuid
      },
      update_expression: 'SET #updated_at = :now, #elo = :new_elo',
      expression_attribute_names: {
        '#updated_at': 'updated_at',
                                   '#elo': 'elo'
      },
      expression_attribute_values: {
        ':now': now,
        ':new_elo': elo_hash[:end_elo],
        ':old_elo': elo_hash[:start_elo],
      },
      return_values: 'ALL_NEW',
      condition_expression: 'elo = :old_elo'
    }

    if elo_hash.has_key?(:season)
      update_hash[:update_expression] += ', #season_elos.#season = :new_season_elo'
      update_hash[:expression_attribute_names].merge!(
        '#season_elos': 'season_elos',
        '#season': elo_hash[:season],
      )
      update_hash[:expression_attribute_values].merge!(
        ':new_season_elo': elo_hash[:end_season_elo]
      )
    end
    client.update_item(update_hash)
  end

  def ban(minecraft_uuid)
    client.update_item({
                         table_name: table_name,
                         key: {
                           minecraft_uuid: minecraft_uuid
                         },
                         update_expression: 'SET #banned = :true, #updated_at = :now, #banned_at = list_append(#banned_at, :now_li)',
                         expression_attribute_names: {
                           '#updated_at': 'updated_at',
                           '#banned': 'banned',
                           '#banned_at': 'banned_at'
                         },
                         expression_attribute_values: {
                           ':now': now,
                           ':now_li': Array.new.push(now),
                           ':true': true,
                           ':minecraft_uuid': minecraft_uuid
                         },
                         condition_expression: 'minecraft_uuid=:minecraft_uuid AND attribute_not_exists(#banned)',
                         return_values: 'ALL_NEW'
                       })
  end

  def unban(minecraft_uuid)
    client.update_item({
                         table_name: table_name,
                         key: {
                           minecraft_uuid: minecraft_uuid
                         },
                         update_expression: 'REMOVE #banned SET #updated_at = :now, #unbanned_at = list_append(#unbanned_at, :now_li)',
                         expression_attribute_names: {
                           '#updated_at': 'updated_at',
                           '#banned':'banned',
                           '#unbanned_at': 'unbanned_at'
                         },
                         expression_attribute_values: {
                           ':now': now,
                           ':now_li': Array.new.push(now),
                           ':minecraft_uuid': minecraft_uuid
                         },
                         condition_expression: 'minecraft_uuid=:minecraft_uuid AND attribute_exists(#banned)',
                         return_values: 'ALL_NEW'
                       })
  end

  def batch_update(batch)
    map = MakeDdbEloUpdateHash.new(batch).hash
    map.each do |k, v|
      update_elo(k, v)
    end
  end

  def get_elo_from_response(response)
    item = response.items.first
    raise NoEloError.new unless ( item.keys.include?('elo') and
      item.keys.include?('season_elos'))
    ret = { elo: item['elo'],
            season_elos: item['season_elos']
          }
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
