require 'lib/ecs_client'
class AutoScaler
  MIN_TASKS = 2
  MAX_TASKS = 12
  MAX_TASK_START_DELAY_SECONDS = 8

  attr_accessor :tasks, :delay, :config

  def min_tasks
    config[:min_tasks] || MIN_TASKS
  end

  def max_task_start_delay_seconds
    config[:max_task_start_delay_seconds] || MAX_TASK_START_DELAY_SECONDS
  end
  
  def initialize(tasks, delay, config)
    @tasks = tasks.clone
    @delay = delay
    @config = config
  end

  def run_task
    @tasks.push(ECSClient.run_task)
  end

  def scale
    if tasks.size < min_tasks
      run_task
      return
    end
    run_task if delay >= max_task_start_delay_seconds
  end
end
