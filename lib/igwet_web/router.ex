defmodule IgwetWeb.Router do
  use IgwetWeb, :router
  require Ueberauth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", IgwetWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/logout", AuthController, :logout)
    resources("/addresses", AddressController)
    resources("/groups", GroupController)
    resources("/edges", EdgeController)
    resources("/events", EventController)
    resources("/messages", MessageController)
    resources("/nodes", NodeController)
    resources("/reminders", ReminderController)
    resources("/users", UserController)
  end

  scope "/webhook", IgwetWeb do
    post("/", WebhookController, :forward_email)
    post("/status", WebhookController, :status)
    post("/log_sms", WebhookController, :log_sms)
    post("/twilio", WebhookController, :receive_sms)
  end

  scope "/rsvp", IgwetWeb do
    pipe_through(:browser)

    get("/", RsvpController, :index)
    get("/to/:event_key", RsvpController, :to_upcoming)
    get("/for/:event_key", RsvpController, :by_event)
    get("/for/:event_key/:email", RsvpController, :by_email)
    post("/for/:event_key/add_email", RsvpController, :add_email)
    post("/for/:event_key/:email/:count", RsvpController, :by_count)
    get("/send_email/:event_key", RsvpController, :send_email)
    get("/remind_rest/:event_key", RsvpController, :remind_rest)
    get("/next/:id", RsvpController, :next_event)
  end

  scope "/auth", IgwetWeb do
    pipe_through(:browser)

    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
    post("/:provider/callback", AuthController, :callback)
  end

  if Application.get_env(:igwet, :env) == :dev do
    # Show Bamboo emails
    forward("/sent_emails", Bamboo.SentEmailViewerPlug)
  end
end
