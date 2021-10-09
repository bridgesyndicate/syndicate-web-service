load 'spec_helper.rb'
require 'lambda/via-stream/games'
require 'lib/helpers'

RSpec.describe '#games stream' do
  let(:event) { JSON.parse(File.read('spec/mocks/stream/game.json')) }
  it 'calls sqs' do
    expect($sqs_manager).to receive(:enqueue)
    handler(event: event, context: {})
  end
end
