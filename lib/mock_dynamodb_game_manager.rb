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

  def update_arn(game_uuid, task_arn)
    if @succeed
      ret_val = OpenStruct.new
      ret_val.data = Aws::DynamoDB::Types::UpdateItemOutput.new
      return ret_val
    else
      ObjectNotFound
    end
  end

  def update_game(game_uuid, game)
    MockDynamoSeahorse.new(Aws::DynamoDB::Types::UpdateItemOutput.new)
  end

  def add_pile_uuid(username, uuid)
    MockDynamoSeahorse.new(Aws::DynamoDB::Types::PutItemOutput.new)
  end

  def put(p)
    MockDynamoSeahorse.new(Aws::DynamoDB::Types::PutItemOutput.new)
  end

  def get(username)
    if username == 'indybooks'
      n_piles = Integer(rand*10) + 1
      ret = [{
               username: username,
               updated_at: Time.now.utc.iso8601,
               created_at: Time.now.utc.iso8601,
               pile_uuid_list: n_piles.times.map { SecureRandom.uuid }
             }]
    else
      ret = {}
    end
      MockDynamoResults.new(ret)
  end
  class ObjectNotFound
  end
end
