[![Build Status](https://semaphoreci.com/api/v1/drernie/igwet/branches/master/badge.svg)](https://semaphoreci.com/drernie/igwet)

# igwet
Intra-Group Web/Email/Text Network Messaging Directory

IGWET is an inside-out social network designed to facilitate external relationships.  Our initial product is a *secure messaging directory* for churches, conferences, singles groups, and other communities that want an easy yet safe way for members to connect around shared interests without having to share sensitive personal information.

IGWET is written in Elixir using the Phoenix web application framework.

## Installation

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Load auth0 envars via, e.g., `source .env`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
