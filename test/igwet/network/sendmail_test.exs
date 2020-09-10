defmodule Igwet.NetworkTest.Sendmail do
  use Igwet.DataCase
  use Bamboo.Test
  doctest Igwet.Network.Sendmail

  alias Igwet.Network.Sendmail

  @group %{id: 4, name: "group.name", email: "group@example.com", key: "group.key"}
  @event %{name: "event.name", email: "event@example.com", about: "This\n\nLine\n\nThat"}

  describe "message" do
    test "email delivery" do
      node = %Igwet.Network.Node{name: "Test", email: "test@example.com"}
      Sendmail.test_email(node) |> Igwet.Admin.Mailer.deliver_now()
      assert_delivered_email Sendmail.test_email(node)
    end

    test "event_message/2" do
      message = Sendmail.event_message(@group, @event)
      assert message.text_body =~ "Line"
    end
  end
end
