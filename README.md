[![Build Status](https://semaphoreci.com/api/v1/drernie/igwet/branches/master/badge.svg)](https://semaphoreci.com/drernie/igwet)

# IGWET
A secure messaging directory for Intra-Group Web/Email/Text.
* www.igwet.com
* www.theswanfactory.com

IGWET is an inside-out social network designed to facilitate external relationships.
Our initial product is a *secure messaging directory* for churches, conferences, singles groups, and other communities that want an easy yet safe way for members to connect with each other and non-members around shared interests, without having to share sensitive personal information.

IGWET is written in Elixir using the Phoenix web application framework.
* https://www.elixir-lang.org
* http://phoenixframework.org

## Installation

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Copy, edit, and load secrets and config via `source .env` from `./example.env`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Production

We recommend Gigalixir.

### Seeds
To update the seeds in production use:
```
$ source .env
$ gigalixir remote_console $APP_NAME
$ Path.join(["#{:code.priv_dir(:igwet)}", "repo", "seeds.exs"]) |> Code.eval_file
```
