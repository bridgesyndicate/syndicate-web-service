require 'lib/ecs_client'
class AutoScaler
  class ScaleInCandidates

    attr_accessor :rows

    def initialize(res)
      @rows = res.ntuples.times
        .map {|n| res[n] }
        .sort{ |a, b| a["id"].to_i <=> b["id"].to_i }
    end

    def has_task?
      !!rows.first
    end

    def task_arn
      rows.first['task_arn']
    end

    def task_pk
      rows.first['id']
    end
  end

  MIN_TASKS = 2
  MAX_TASKS = 12
  MAX_TASK_START_DELAY_SECONDS = 8

  attr_accessor :tasks, :delay, :config, :sql_client, :ecs_client

  def min_tasks
    config[:min_tasks] || MIN_TASKS
  end

  def max_tasks
    config[:max_tasks] || MAX_TASKS
  end

  def max_task_start_delay_seconds
    config[:max_task_start_delay_seconds] || MAX_TASK_START_DELAY_SECONDS
  end

  def initialize(tasks, delay, config)
    @tasks = tasks.clone
    @delay = delay
    @config = config
    @ecs_client = ECSClient.new(
      tasks_subnet: config[:tasks_subnet],
      tasks_security_group: config[:tasks_security_group])
  end

  def set_sql_client(client)
    @sql_client = client
  end

  def run_task
    syn_logger 'running new task'
    @tasks.push(ecs_client.run_task)
  end

  def stop_task(task_arn)
    syn_logger "stopping task #{task_arn}"
    ecs_client.stop_task(task_arn)
    @tasks = tasks.reject { |e| e == task_arn }
  end

  def set_as_terminated(pk)
    sql_client.update_terminated_row(pk)
  end

  def accept_candidate?
    delay < max_task_start_delay_seconds and
    tasks.size > min_tasks
  end

  def insert_candidate(task_arn)
    sql_client.insert_candidate(task_arn)
  end

  def first_candidate?(task_arn)
    candidates = ScaleInCandidates.new(sql_client.get_scale_in_candidates)
    candidates.has_task? and task_arn == candidates.task_arn
  end

  def scale
    candidates = ScaleInCandidates.new(sql_client.lock_scale_in_candidates)
    if candidates.has_task?
      stop_task(candidates.task_arn)
      set_as_terminated(candidates.task_pk)
      return
    end

    if tasks.size < min_tasks
      run_task
      return
    end
    run_task if tasks.size < max_tasks and delay >= max_task_start_delay_seconds
  end
end
