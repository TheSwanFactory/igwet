defmodule Igwet.NetworkTest.Message do
  use Igwet.DataCase
  use Bamboo.Test
  doctest Igwet.Network.Message

  alias Igwet.Network.Message

  describe "message" do
    test "email delivery" do
      node = %Igwet.Network.Node{name: "Test", email: "test@example.com"}
      Message.test_email(node) |> Igwet.Admin.Mailer.deliver_now()
      assert_delivered_email(Message.test_email(node))
    end
  end
end
