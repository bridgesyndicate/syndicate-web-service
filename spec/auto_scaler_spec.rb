load 'spec_helper.rb'
require 'helpers'
require 'auto_scaler'

RSpec.describe '#auto_scaler' do

  describe 'for MIN and MAX' do
    let(:delay) { AutoScaler::MAX_TASK_START_DELAY_SECONDS - 1 }
    let(:config) { {} }
    before(:each) do
      stub_request(:post, 'https://ecs.us-east-2.amazonaws.com/')
        .to_return(status: 200,
                   body: File.read('spec/mocks/web-mock-ecs-run-task/success.json'),
                   headers: {})
      @auto_scaler = AutoScaler.new(current_tasks, delay, config)
      @auto_scaler.scale
    end

    describe 'with less than MIN task' do
      let(:current_tasks) { [SecureRandom.uuid] }
      it 'adds a task when below MIN' do
        expect(@auto_scaler.tasks.size).to eq 2
      end
    end

    describe 'with more than MIN and less than MAX' do
      let(:current_tasks) {random_number_of_tasks.times.map { SecureRandom.uuid } }

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
end
