defmodule Igwet.Scheduler do
  use Quantum, otp_app: :igwet_app
  alias Crontab.CronExpression

  def node_job(node) do
    cron = node_cron(node)
    name = String.to_atom(node.key)
    new_job()
    |> Quantum.Job.set_name(name)
    |> Quantum.Job.set_timezone(node.timezone)
    |> Quantum.Job.set_schedule(cron)
    |> Quantum.Job.set_task(fn -> :ok end)
    |> add_job()
    find_job(name)
  end

  def node_cron(node) do
    recurrence = if (node.meta), do: node.meta.recurrence, else: 7
    if (!is_nil(node.date) and recurrence == 7) do
      hour = node.date.hour
      minute = node.date.minute
      %CronExpression{minute: [minute], hour: [hour]}
    end
  end

  def get_job(node) do
    job = node.key |> String.to_atom() |> find_job()
    if (job), do: job, else: node_job(node)
  end

  def node_set_status(node, _flag) do
    get_job(node)
  end

end
