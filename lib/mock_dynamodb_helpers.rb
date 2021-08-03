class MockDynamoResults
  attr_accessor :items
  def initialize(items)
    @items = items
  end
end

class MockDynamoSeahorse
  attr_accessor :data
  def initialize(data)
    @data = data
  end
end
