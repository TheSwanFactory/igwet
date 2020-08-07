[![Build Status](https://drernie.semaphoreci.com/badges/igwet.svg?style=shields)](https://drernie.semaphoreci.com)

# IGWET
A secure messaging directory for Intra-Group Web/Email/Text.
* www.igwet.com
* theswanfactory.wordpress.com

IGWET is an inside-out social network designed to facilitate external relationships.
Our initial product is a *secure messaging directory* for churches, conferences, singles groups, and other communities that want an easy yet safe way for members to connect with each other and non-members around shared interests, without having to share sensitive personal information.

IGWET is written in Elixir using the Phoenix web application framework.
* https://www.elixir-lang.org
* http://phoenixframework.org

## Installation


To initialize the database:

```
$ brew install postgres && brew services start postgresql
# OR $ brew postgresql-upgrade-database
$ createuser phx -s -P
# elixir
$ createuser runner -s -P
# semaphoredb
$ psql postgres -c "\du"


```

To start your Phoenix server:
```
$ brew upgrade npm # or install
$ brew install elixir
$ mix deps.get                          # Install dependencies
$ mix compile
$ mix ecto.create && mix ecto.migrate   # Create and migrate your database
$ mix run priv/repo/seeds.exs           # Run seeds
$ cd assets && npm install && cd ..             # Install Node.js dependencies
$ cp ./example.env .env && $(EDITOR) .env && source .env    # Configure secrets
$ mix test
$ mix phx.server                        # Run app via Cowboy web server
$ open http://0.0.0.0:4000
```


Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

You can test the webhook via:
```
$ curl -d "@test-message.json" -H "Content-Type: application/json" -X POST http://localhost:4000/webhook
$ open http://localhost:4000/sent_emails

```

## Production

We recommend Gigalixir.
```
$ brew tap gigalixir/brew && brew install gigalixir
$ gigalixir --help
$ gigalixir signup # if not already
$ gigalixir login
$ gigalixir account
$ gigalixir create -n igwet
$ gigalixir apps
$ git remote -v
$ gigalixir pg:create --free
$ gigalixir pg
$ gigalixir config
$ git push gigalixir master
$ gigalixir open
$ ssh-keygen -t rsa # if you have never done so before
$ gigalixir account:ssh_keys:add "$(cat ~/.ssh/id_rsa.pub)"
$ gigalixir ps:migrate
```

### Seeds
To update the seeds in production use:
```
$ source .env
$ gigalixir remote_console -a $APP_NAME
$ Path.join(["#{:code.priv_dir(:igwet)}", "repo", "seeds.exs"]) |> Code.eval_file
```
