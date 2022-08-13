load 'spec_helper.rb'
require 'lib/helpers'
require 'timecop'
require 'lambda/via-stream/games'
require 'lib/game_stream'

RSpec.describe '#games stream' do
  let(:event) { JSON.parse(File.read'spec/mocks/stream/game-red-wins-2x2.json') }
  let(:game_stream) { GameStream.new(Aws::DynamoDBStreams::AttributeTranslator
                                       .from_event(event).first)
  }

  shared_examples 'end-of-match processing for all' do
    before() do
      game_stream.compute_elo_changes
    end
    it 'computes elo changes in pairs' do
      expect(game_stream.batch.size).to eq num_pairs
    end
  end

  shared_examples 'end-of-match processing for non-ties' do
    before() do
      game_stream.compute_elo_changes
    end
    it 'computes the right winners' do
      expect(game_stream.batch.map {|p| p.winner.discord_name }
             .sort).to eq winners
    end
    it 'computes the right losers' do
      expect(game_stream.batch.map {|p| p.loser.discord_name }
             .sort).to eq losers
    end
    it 'increases the winners elo' do
      expect(game_stream.batch.map {|p| p.winner.end_elo - p.winner.start_elo })
        .to all(be_positive)
    end
    it 'decreases the losers elo' do
      expect(game_stream.batch.map {|p| p.loser.end_elo - p.loser.start_elo })
        .to all(be_negative)
    end
  end

  describe 'red-wins-2x2' do
    let(:event) { JSON.parse(File.read'spec/mocks/stream/game-red-wins-2x2.json') }
    let(:num_pairs) {2}
    let(:winners) { %w/bdamja ken/ }
    let(:losers) { %w/ellis viceversa/ }
    it_behaves_like 'end-of-match processing for all'
    it_behaves_like 'end-of-match processing for non-ties'
  end

  describe 'blue-wins-1x1' do
    let(:event) { JSON.parse(File.read('spec/mocks/stream/game-blue-wins-1x1.json')) }
    let(:num_pairs) {1}
    let(:winners) { %w/viceversa/ }
    let(:losers) { %w/bdamja/ }
    it_behaves_like 'end-of-match processing for all'
    it_behaves_like 'end-of-match processing for non-ties'
  end

  describe 'red-wins-1x1' do
    let(:event) { JSON.parse(File.read('spec/mocks/stream/game-red-wins-1x1.json')) }
    let(:num_pairs) {1}
    let(:winners) { %w/bdamja/ }
    let(:losers) { %w/viceversa/ }
    it_behaves_like 'end-of-match processing for all'
    it_behaves_like 'end-of-match processing for non-ties'
  end

  describe 'tie-2x2' do
    let(:event) { JSON.parse(File.read'spec/mocks/stream/game-tie-2x2.json') }
    let(:num_pairs) {2}
    let(:winners) { %w/bdamja ken/ }
    let(:losers) { %w/viceversa ellis/ }
    it_behaves_like 'end-of-match processing for all'
    before() do
      game_stream.compute_elo_changes
    end
    it 'changes elos by half' do
      expect(game_stream.batch.map {|p| p.winner.end_elo - p.winner.start_elo })
        .to eq [9,8] # see note in games.rb about who is the winner, sorry.
    end
  end

  describe 'tie-1x1' do
    let(:event) { JSON.parse(File.read'spec/mocks/stream/game-tie-1x1.json') }
    let(:num_pairs) {1}
    let(:winners) { %w/bdamja/ }
    let(:losers) { %w/viceversa/ }
    before() do
      game_stream.compute_elo_changes
    end
    it 'changes elos by half' do
      expect(game_stream.batch.map {|p| p.winner.end_elo - p.winner.start_elo })
        .to eq [12]
    end
    describe 'another tie-1x1' do
      let(:event) { JSON.parse(File.read'spec/mocks/stream/another-game-tie-1x1.json') }
      it 'changes elos by half' do
        expect(game_stream.batch.map {|p| p.winner.end_elo - p.winner.start_elo })
          .to eq [7]
      end
    end
  end

  describe 'handler' do
    it 'calls dynamo' do
      expect($sqs_manager).to receive(:enqueue).once
      expect($ddb_user_manager).to receive(:batch_update).once
      handler(event: event, context: {})
    end
  end

  describe 'sqs message' do
    it 'contains the elo changes' do
      allow($ddb_user_manager).to receive(:batch_update)
      expect($sqs_manager).to receive(:enqueue)
                                .with('player_messages',
                                      File.read('spec/mocks/stream/sqs-with-elo.json').chop)
      handler(event: event, context: {})
    end
  end

  describe 'postgres' do
    describe 'without a tie' do
      it 'update the database when winners and loser exist' do
        expect($sqs_manager).to receive(:enqueue).once
        expect($ddb_user_manager).to receive(:batch_update).once
        expect($pg_conn).to receive(:exec_prepared)
                              .with('update_winner', any_args)
                              .ordered
                              .and_return(PostgresClient::Tuples.new(1)).exactly(2)
        expect($pg_conn).to receive(:exec_prepared)
                              .with('update_loser', any_args)
                              .ordered
                              .and_return(PostgresClient::Tuples.new(1)).exactly(2)
        handler(event: event, context: {})
      end
      it 'creates users' do
        expect($sqs_manager).to receive(:enqueue).once
        expect($ddb_user_manager).to receive(:batch_update).once
        expect($pg_conn).to receive(:exec_prepared)
                              .with('update_winner', any_args)
                              .ordered
                              .and_return(PostgresClient::Tuples.new(0)).exactly(2)
        expect($pg_conn).to receive(:exec_prepared)
                              .with('new_winner', any_args)
                              .ordered
                              .and_return(PostgresClient::Tuples.new(0)).exactly(2)
        expect($pg_conn).to receive(:exec_prepared)
                              .with('update_loser', any_args)
                              .ordered
                              .and_return(PostgresClient::Tuples.new(0)).exactly(2)
        expect($pg_conn).to receive(:exec_prepared)
                              .with('new_loser', any_args)
                              .ordered
                              .and_return(PostgresClient::Tuples.new(0)).exactly(2)
        handler(event: event, context: {})
      end
    end
    describe 'with a tie' do
      let(:event) { JSON.parse(File.read'spec/mocks/stream/game-tie-1x1.json') }
      it 'update the existing users' do
        expect($sqs_manager).to receive(:enqueue).once
        expect($ddb_user_manager).to receive(:batch_update).once
        expect($pg_conn).to receive(:exec_prepared)
                              .with('update_tie', any_args)
                              .and_return(PostgresClient::Tuples.new(1)).exactly(2)
        handler(event: event, context: {})
      end
      it 'creates users' do
        expect($sqs_manager).to receive(:enqueue).once
        expect($ddb_user_manager).to receive(:batch_update).once
        expect($pg_conn).to receive(:exec_prepared)
                              .with('update_tie', any_args)
                              .ordered
                              .and_return(PostgresClient::Tuples.new(0)).exactly(1)
        expect($pg_conn).to receive(:exec_prepared)
                              .with('new_tie', any_args)
                              .ordered
                              .and_return(PostgresClient::Tuples.new(0)).exactly(1)
        expect($pg_conn).to receive(:exec_prepared)
                              .with('update_tie', any_args)
                              .ordered
                              .and_return(PostgresClient::Tuples.new(0)).exactly(1)
        expect($pg_conn).to receive(:exec_prepared)
                              .with('new_tie', any_args)
                              .ordered
                              .and_return(PostgresClient::Tuples.new(0)).exactly(1)
        handler(event: event, context: {})
      end
    end
  end
  describe 'DynamoDDB calls' do
    before(:each) {
      # https://github.com/travisjeffery/timecop/issues/41
      Timecop.freeze(Time.parse('Tue Oct 19 15:37:00 PDT 2021').utc)
      stub_request(:post, "http://localhost:8000/")
        .with(
          body: build_test_json(uuid: '2b7fa93b-f690-46b8-bfe6-a07b2ec42563',
                                 elo: '999'))
        .to_return(status: 200, body: "", headers: {})
      stub_request(:post, "http://localhost:8000/")
        .with(
          body: build_test_json(uuid: 'f0885cea-8291-4734-be1b-bf37f6bcab7c',
                                 elo: '1191'))
        .to_return(status: 200, body: "", headers: {})
      stub_request(:post, "http://localhost:8000/")
        .with(
          body: build_test_json(uuid: 'eb7fa93b-f690-46b8-bfe6-a07b2ec42563',
                                 elo: '2215'))
        .to_return(status: 200, body: "", headers: {})
      stub_request(:post, "http://localhost:8000/")
        .with(
          body: build_test_json(uuid: 'e1185cea-8291-4734-be1b-bf37f6bcab7c',
                                 elo: '2285'))
        .to_return(status: 200, body: "", headers: {})
    }
    it 'udpates ddb' do
      expect($sqs_manager).to receive(:enqueue).once
      handler(event: event, context: {})
    end
    describe 'does not enqueue a message for a newly inserted dynamo record' do
      let(:event) { JSON.parse(File.read'spec/mocks/stream/newly-queued-1x1.json') }
      it 'does not queue a sqs' do
        expect($sqs_manager).to_not receive(:enqueue)
        handler(event: event, context: {})
      end
    end
    describe 'enqueues a message when the game update its task ip' do
      let(:event) { JSON.parse(File.read'spec/mocks/stream/updated-task-ip.json') }
      it 'sends a message' do
        expect($sqs_manager).to receive(:enqueue).once
        handler(event: event, context: {})
      end
    end
    describe 'sends sqs when game is aborted' do
      let(:event) { JSON.parse(File.read'spec/mocks/stream/game-modify-with-abort.json') }
      it '' do
        expect($sqs_manager).to receive(:enqueue)
        handler(event: event, context: {})
      end
    end
  end
end
