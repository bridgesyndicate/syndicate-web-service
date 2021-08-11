class SyndicateRandomUuid
  def self.uuid
    if SYNDICATE_ENV == 'test'
      'a61ab839-44cb-471d-8534-7110397fbf2c'
    else
      SecureRandom.uuid
    end
  end
end
