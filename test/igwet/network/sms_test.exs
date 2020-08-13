defmodule Igwet.NetworkTest.SMS do
  use Igwet.DataCase
  doctest Igwet.Network.SMS

  alias Igwet.Network.SMS

  describe "SMS" do
    test "text delivery" do
      node = %Igwet.Network.Node{name: "Test", email: "test@example.com"}
      #Sendmail.test_email(node) |> Igwet.Admin.Mailer.deliver_now()
      #assert_delivered_email(Sendmail.test_email(node))
    end
  end
end
