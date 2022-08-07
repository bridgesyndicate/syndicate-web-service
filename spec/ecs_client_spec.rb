load 'spec_helper.rb'
require 'helpers'
require 'ecs_client'

RSpec.describe '#cloudwatch_client' do

  let(:ecs_client) { ECSClient.new }

  describe 'for the client' do
    it 'gets a client' do
      expect(ecs_client.client).to be_a Aws::ECS::Client
    end
  end

  describe 'task list' do
    before(:each) do
      stub_request(:post, 'https://ecs.us-east-1.amazonaws.com/')
        .to_return(status: 200,
                   body: File.read('spec/mocks/web-mock-ecs-list-tasks/one-task.json'),
                   headers: {})
    end
    it 'gets the task list' do
      expect(ecs_client.list_tasks.task_arns.size).to eq 1
    end
  end

  describe 'run task' do
    let(:ecs_client) { ECSClient.new(
                         tasks_subnet: SecureRandom.uuid,
                         tasks_security_group: SecureRandom.uuid
                       )
    }

    before(:each) do
      stub_request(:post, 'https://ecs.us-east-1.amazonaws.com/')
        .to_return(status: 200,
                   body: File.read('spec/mocks/web-mock-ecs-run-task/success.json'),
                   headers: {})
    end

    it 'launches a task' do
      expect(ecs_client.run_task).to match %r!arn:aws:ecs:us-east-2:595508394202:task/SyndicateECSCluster/[a-z0-9]{32}!
    end
  end

  describe 'stop task' do
    before(:each) do
       stub_request(:post, "https://ecs.us-east-1.amazonaws.com/")
        .to_return(status: 200, body: File.read('spec/mocks/web-mock-ecs-stop_task/success.json'))

    end

    let(:task_arn) { 'arn:aws:ecs:us-east-1:595508394202:task/SyndicateECSCluster/250d85bc107e4dcbb39666340c2a3d1e' }

    it 'stops a task' do
      expect(ecs_client.stop_task(task_arn)).to be_a Seahorse::Client::Response
    end
  end
end
