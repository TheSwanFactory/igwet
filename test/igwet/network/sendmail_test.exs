defmodule Igwet.NetworkTest.Sendmail do
  use Igwet.DataCase
  use Bamboo.Test
  doctest Igwet.Network.Sendmail

  alias Igwet.Network.Sendmail

  describe "message" do
    test "email delivery" do
      node = %Igwet.Network.Node{name: "Test", email: "test@example.com"}
      Sendmail.test_email(node) |> Igwet.Admin.Mailer.deliver_now()
      assert_delivered_email Sendmail.test_email(node)
    end

    test "sender_params/2" do
    end

    test "email_group_event/2" do
    end
  end
end
