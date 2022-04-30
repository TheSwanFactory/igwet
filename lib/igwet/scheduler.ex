defmodule Igwet.Scheduler do
  use Quantum, otp_app: :igwet_app
  alias Crontab.CronExpression
  alias IgwetWeb.RsvpController
  require Logger

  def create_job_for_node(node) do
    cron = node_cron(node)
    name = String.to_atom(node.key)
    new_job()
    |> Quantum.Job.set_name(name)
    |> Quantum.Job.set_timezone(node.timezone)
    |> Quantum.Job.set_schedule(cron)
    |> Quantum.Job.set_task(fn -> perform_task(node) end)
    |> add_job()
    find_job(name)
  end

  def node_cron(node) do
    recurrence = if (node.meta), do: node.meta.recurrence, else: 7
    if (!is_nil(node.date) and recurrence == 7) do
      hour = node.date.hour
      minute = node.date.minute
      weekday = Date.day_of_week(node.date)
      %CronExpression{minute: [minute], hour: [hour], weekday: [weekday]}
    end
  end

  def get_job_for_node(node) do
    job = node.key |> String.to_atom() |> find_job()
    if (job), do: job, else: create_job_for_node(node)
  end

  def delete_job_for_node(node) do
    node.key |> String.to_atom() |> delete_job()
  end

  def run_job_for_node(node) do
    node.key |> String.to_atom() |> run_job()
  end

  def perform_task(node) do
    try do
      method = String.to_existing_atom(node.about)
      #Logger.warn("perform_task '#{method}' for #{node.name}")
      apply(RsvpController, method, [node])
    rescue
      e ->
        Logger.warn("#{e.message}:perform_task:#{node.key}:about='#{node.about}'")
      inspect(e)
    end
  end

  def node_set_status(node, flag) do
    job = get_job_for_node(node)
    if (flag) do
      activate_job(job.name)
    else
      deactivate_job(job.name)
    end
    find_job(job.name)
  end

end
