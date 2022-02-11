require 'time'
require 'ostruct'
require 'lib/object_not_found'

class MockDynamodbGameManager
  attr_accessor :client, :table_name, :succeed
  def initialize(region: nil,
                 table_name: nil,
                 endpoint: nil)

    @table_name = "syndicate_#{SYNDICATE_ENV}_games"

    @client = {
      region:      region,
      endpoint:    endpoint
    }
    @succeed = true
  end

  def update_game(game_uuid, game)
    ret_val = OpenStruct.new
    ret_val.data = Aws::DynamoDB::Types::UpdateItemOutput.new
    uuids = get_srandom_minecraft_uuids
    ret_val.attributes = {
      'game' => {
        'blue_team_minecraft_uuids' => uuids[0, uuids.size/2],
        'red_team_minecraft_uuids' => uuids[uuids.size/2, uuids.size]
      }
    }
    return ret_val
  end

  def put(p)
    MockDynamoSeahorse.new(Aws::DynamoDB::Types::PutItemOutput.new)
  end
end
