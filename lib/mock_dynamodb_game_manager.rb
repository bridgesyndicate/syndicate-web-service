require 'time'
require 'ostruct'

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

  def update_task_ip(game_uuid, task_arn)
    if @succeed
      ret_val = OpenStruct.new
      ret_val.data = Aws::DynamoDB::Types::UpdateItemOutput.new
      t = rand(4) + 1
      ret_val.attributes = {
        'game' => {
          'blue_team_minecraft_uuids' =>  t.times.map {SecureRandom.uuid},
          'red_team_minecraft_uuids' =>  t.times.map {SecureRandom.uuid}
        }
      }
      return ret_val
    else
      ObjectNotFound
    end
  end

  def update_game(game_uuid, game)
    ret_val = OpenStruct.new
    ret_val.data = Aws::DynamoDB::Types::UpdateItemOutput.new
    t = rand(4) + 1
    ret_val.attributes = {
      'game' => {
        'blue_team_minecraft_uuids' =>  t.times.map {SecureRandom.uuid},
        'red_team_minecraft_uuids' =>  t.times.map {SecureRandom.uuid}
      }
    }
    return ret_val
  end

  def add_pile_uuid(username, uuid)
    MockDynamoSeahorse.new(Aws::DynamoDB::Types::PutItemOutput.new)
  end

  def put(p)
    MockDynamoSeahorse.new(Aws::DynamoDB::Types::PutItemOutput.new)
  end

  class ObjectNotFound
  end
end
