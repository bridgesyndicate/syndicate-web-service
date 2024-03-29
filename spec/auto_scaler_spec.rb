load 'spec_helper.rb'
require 'helpers'
require 'auto_scaler'

class PGResultsMock
  attr_accessor :rows
  def initialize rows
    @rows = rows
  end

  def ntuples
    rows.size
  end

  def [](idx)
    rows[idx]
  end
end

RSpec.describe '#auto_scaler' do
  describe 'for MIN and MAX' do
    let(:delay) { AutoScaler::MAX_TASK_START_DELAY_SECONDS - 1 }
    let(:config) { {
                     tasks_subnet: 'subnet-02f0a2e9ba4b5d279',
                     tasks_security_group: 'sg-0cde2458dac7fcd35'
                   }
    }

    before(:each) do
      stub_request(:post, 'https://ecs.us-east-1.amazonaws.com/')
        .to_return(status: 200,
                   body: File.read('spec/mocks/web-mock-ecs-run-task/success.json'),
                   headers: {})
      sql = double('sql')
      allow(sql).to receive(:lock_scale_in_candidates)
        .and_return(PGResultsMock.new([]))
      @auto_scaler = AutoScaler.new(current_tasks, delay, config)
      @auto_scaler.set_sql_client(sql)
      @auto_scaler.scale
    end

    describe 'with less than MIN task' do
      let(:current_tasks) { [SecureRandom.uuid] }
      it 'adds a task when below MIN' do
        expect(@auto_scaler.tasks.size).to eq 2
      end
    end

    describe 'with more than MIN and less than MAX' do
      let(:current_tasks) { (random_number_of_tasks - 1).times.map { SecureRandom.uuid } }

      it 'does not add a task when the delay is under MAX_TASK_START_DELAY_SECONDS' do
        expect(@auto_scaler.tasks.size).to eq current_tasks.size
      end

      describe 'with delay over MAX_DELAY' do
        let(:delay) { AutoScaler::MAX_TASK_START_DELAY_SECONDS + 1 }
        it 'adds a task' do
          expect(@auto_scaler.tasks.size).to eq (current_tasks.size + 1)
        end
      end
    end

    describe 'with MAX tasks' do
      let(:current_tasks) { AutoScaler::MAX_TASKS.times.map { SecureRandom.uuid} }
      let(:delay) { AutoScaler::MAX_TASK_START_DELAY_SECONDS + 1 }
      it 'does not add a task when above MAX and over MAX_DELAY' do
        expect(@auto_scaler.tasks.size).to eq AutoScaler::MAX_TASKS
      end
    end

    describe 'with not tasks and MIN set to zero, idle' do
      let(:current_tasks) { [] }
      let(:config) {
        {
          min_tasks: 0
        }
      }
      it 'does not add a task when set to idle' do
        expect(@auto_scaler.tasks.size).to eq 0
      end
    end
  end

  describe 'scale in candidates' do
    let(:config) { {} }
    let(:delay) { 0 }
    before(:each) do
      sql = double('sql')
      allow(sql).to receive(:insert_candidate)
      allow(sql).to receive(:get_scale_in_candidates)
          .and_return(
                      PGResultsMock.new(
                                        current_tasks.each_with_index.map { |t, i| {
                                            id: (i + 1).to_s,
                                            created_at: Time.now,
                                            task_arn: t,
                                            processed: 'f',
                                            terminated: 'f'
                                          }
                                            .transform_keys(&:to_s)
                                        })
                      )
      @auto_scaler = AutoScaler.new(current_tasks, delay, config)
      @auto_scaler.set_sql_client(sql)
    end

    describe 'when there are MIN tasks' do
      let(:current_tasks) { AutoScaler::MIN_TASKS.times.map { SecureRandom.uuid } }

      it 'rejects the candidate (404) when there are MIN tasks' do
        expect(@auto_scaler.accept_candidate?).to be false
      end
    end

    describe 'when tasks are MIN < tasks MAX and delay is high' do
      let(:current_tasks) { 5.times.map { SecureRandom.uuid } }
      let(:delay) { 100 }

      it 'rejects the candidate' do
        expect(@auto_scaler.accept_candidate?).to be false
      end

      describe 'delay is low' do
        let(:delay) { 1 }

        it 'accepts the candidate' do
          expect(@auto_scaler.accept_candidate?).to be true
        end

        it 'is the first candidate' do
          @auto_scaler.insert_candidate(current_tasks.first)
          expect(@auto_scaler.first_candidate?(current_tasks.first)).to be true
        end

        it 'is not the first candidate' do
          @auto_scaler.insert_candidate(current_tasks[0])
          @auto_scaler.insert_candidate(current_tasks[1])
          expect(@auto_scaler.first_candidate?(current_tasks[1])).to be false
        end
      end
    end
  end

  describe 'scheduled scaling in' do
    let(:delay) { AutoScaler::MAX_TASK_START_DELAY_SECONDS - 1 }
    let(:config) { {} }
    before(:each) do
      stub_request(:post, 'https://ecs.us-east-1.amazonaws.com/')
        .to_return(status: 200,
                   body: File.read('spec/mocks/web-mock-ecs-run-task/success.json'),
                   headers: {})
      @auto_scaler = AutoScaler.new(current_tasks, delay, config)
    end

    describe 'with a scale in task' do
      let(:current_tasks) { random_number_of_tasks.times.map { SecureRandom.uuid } }
      before(:each) do
        sql = double('sql')
        allow(sql).to receive(:update_terminated_row)
        allow(sql).to receive(:lock_scale_in_candidates)
          .and_return(
                      PGResultsMock.new(
                                        current_tasks.each_with_index.map { |t, i| {
                                            id: (i + 1).to_s,
                                            created_at: Time.now,
                                            task_arn: t,
                                            processed: 'f',
                                            terminated: 'f'
                                          }
                                            .transform_keys(&:to_s)
                                        })
                      )
        @auto_scaler.set_sql_client(sql)
        @auto_scaler.scale
      end

      #let(:current_tasks) { %w/foobarbaz1 foobarbaz2 foobarbaz3/}

      it 'scales in' do
        expect(@auto_scaler.tasks.size).to eq (current_tasks.size - 1)
      end
    end
  end
end
