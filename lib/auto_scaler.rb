require 'lib/ecs_client'
class AutoScaler
  MIN_TASKS = 2
  MAX_TASKS = 12
  MAX_TASK_START_DELAY_SECONDS = 8

  attr_accessor :tasks, :delay
  
  def initialize(tasks, delay)
    @tasks = tasks.clone
    @delay = delay
  end

  def run_task
    @tasks.push(ECSClient.run_task)
  end

  def scale
    if tasks.size < MIN_TASKS
      run_task
      return
    end
    run_task if delay >= MAX_TASK_START_DELAY_SECONDS
  end
end
