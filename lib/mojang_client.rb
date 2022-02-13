require 'faraday'

class MojangClient

  class NotFoundError < StandardError
    def initialize(m)
      msg = m
      super
    end
  end

  MOJANG_URL = 'https://api.mojang.com/users/profiles/minecraft/'
  NOT_FOUND = 'Mojang cannot find this username'

  def self.resolve(username)
    url = MOJANG_URL + username
    response = Faraday.get(url)
    raise NotFoundError.new(NOT_FOUND) if response.status != OK
    return response
  end

end
