OK = 200
BAD_REQUEST = 400
NOT_FOUND = 404
SERVER_ERROR = 500
SYNDICATE_ENV = ENV['SYNDICATE_ENV']
FORBIDDEN = 403
UUID_REGEX = /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/
KICK_CODE_REGEX = /[a-zA-z0-9]{16}/
GAME='game'
DELAYED_WARPS='delayed_warps'
MINECRAFT_PORT=2556

def get_cognito_username ctx
  ctx['requestContext']['authorizer']['claims']["cognito:username"]
end

def get_srandom_minecraft_uuids
  srand(ENV['srand'].to_i)
  (rand(4) + 1).times.map {random_uuid}
end

def random_uuid
  [Random.bytes(4).unpack("H*"),
   Random.bytes(2).unpack("H*"),
   Random.bytes(2).unpack("H*"),
   Random.bytes(2).unpack("H*"),
   Random.bytes(6).unpack("H*")].join('-')
end
