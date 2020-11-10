defmodule Igwet.Scheduler do
  use Quantum, otp_app: :igwet_app
  alias Crontab.CronExpression

  def node_job(node) do
    cron = node_cron(node)
    new_job()
    |> Quantum.Job.set_name(node.key)
    |> Quantum.Job.set_timezone(node.timezone)
    |> Quantum.Job.set_schedule(cron)
    |> Quantum.Job.set_task(fn -> :ok end)
    |> add_job()
  end

  def node_cron(node) do
    recurrence = if (node.meta), do: node.meta.recurrence, else: 7
    if (node.date and recurrence == 7) do
      hour = node.date.hour
      minute = node.date.minute
      CronExpression.Composer.compose %CronExpression{minute: minute, hour: hour}
    end
  end

end
