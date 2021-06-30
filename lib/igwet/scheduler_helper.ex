# Sample email: http://bin.mailgun.net/b1748eea#7jmd

defmodule Igwet.Scheduler.Helper do
  require Logger
  alias Igwet.Network
  alias Igwet.Network.SMS
  alias Igwet.Network.Sendmail
  alias Igwet.Admin.Mailer
  @server "https://www.igwet.com"

  def email_member(message, member, url) do
    try do
      Sendmail.to_member(message, member, url) |> Mailer.deliver_now()
    rescue
      e in Bamboo.ApiError -> Logger.error("failed.send_email.member\n#{inspect(member)}\n#{inspect(e)}")
    end
  end

  def sms_event_owner(message, event) do
    if (event.phone) do
      %{debug: true, to: event.phone, body: message}
      |> Map.put(:from, System.get_env("PHONE_IGWET"))
      |> SMS.send_message()
    end
  end

  def email_event(event) do
    group = Network.get_node!(event.meta.parent_id)
    message = Sendmail.event_message(group, event)
    result = for member <- Network.node_members(group) do
      if (member.email && (member.email =~ "@")) do
        # https://www.igwet.com/rsvp/for/us.kingsway.0kss_2021-02-21/ernest%40drernie.com
        email = String.replace(member.email, "@", "%40")
        url = @server <> "/rsvp/for/" <> event.key <> "/" <> email
        email_member(message, member, url)
        member.email
      end
    end
    "#{Enum.count(result)} emails sent\n #{inspect result}"
  end

  def email_upcoming(node) do
    %{name: pattern, about: action} = node
    event = Network.last_event!(pattern)
    upcoming =
      Network.upcoming_event!(event.key)
      |> Map.put(:about, action)
    email_event(upcoming)
  end

  def test(event) do
    Logger.warn("RSVP.test: #{event.key}")
  end
end
