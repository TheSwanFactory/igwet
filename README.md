[![Build Status](https://drernie.semaphoreci.com/badges/igwet.svg?style=shields)](https://drernie.semaphoreci.com)

# IGWET v0.2.2
An Open Source secure messaging directory for Intra-Group Web/Email/Text. Available as a commercial service at [www.igwet.com](https://www.igwet.com).

IGWET is an inside-out social network designed to facilitate external relationships.
Our initial product is a *secure messaging directory* for churches, conferences, singles groups, and other communities that want an easy yet safe way for members to connect with each other and non-members around shared interests, without having to share sensitive personal information.

IGWET is written in [Elixir](https://www.elixir-lang.org) using the [Phoenix](http://phoenixframework.org) web application framework.

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
$ psql postgres -c "\l"


```

To start your Phoenix server:
```
$ brew upgrade npm # or install
$ brew install elixir # or brew upgrade
$ mix deps.get                          # Install dependencies
$ mix compile
$ mix ecto.create && mix ecto.migrate   # Create and migrate your database
$ mix run priv/repo/seeds.exs           # Run seeds
$ openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" -keyout priv/server.key -out priv/server.pem
$ cd assets && npm install &We & npm run deploy && npx browserslist@latest --update-db && cd ..  # Install Node stuff
$ cp ./example.env .env && $(EDITOR) .env # Configure secrets (if never done before)
$ source .env
$ mix phx.digest
$ mix test
$ mix phx.server                        # Run app via Cowboy web server
$ open https://localhost:4000           # Ignore warning about certificate
```


Now you can visit [`localhost:4000`](https://localhost:4000) from your browser.

You can test the webhook via:
```
$ curl -d "@test-message.json" -H "Content-Type: application/json" -X POST https://localhost:4000/webhook
$ open https://localhost:4000/sent_emails

```

## Production

We recommend [Gigalixir](https://gigalixir.readthedocs.io/en/latest/modify-app/releases.html).
```
$ brew tap gigalixir/brew && brew install gigalixir
$ gigalixir --help
$ gigalixir signup # if not already
$ gigalixir login
$ gigalixir account
$ gigalixir apps
$ gigalixir create -n igwet # if not already
$ gigalixir pg
$ gigalixir pg:create --free # if not already
$ gigalixir config
$ git remote -v
$ git push gigalixir master
$ gigalixir open
$ ssh-keygen -t rsa # if you have never done so before
$ gigalixir account:ssh_keys:add "$(cat ~/.ssh/id_rsa.pub)"
$ gigalixir ps:migrate
```

### Production Releases
If you have the githook installed, just do `mix version.up`
Otherwise:
```
$ export SECRET_KEY_BASE="$(mix phx.gen.secret)"
$ export DATABASE_URL="postgresql://phx:elixir@localhost:5432/igwet_dev" # can put this in .env
$ MIX_ENV=prod mix release
$ MIX_ENV=prod _build/prod/rel/igwet/bin/igwet daemon
$ curl open
```

### Overwrite Production Seeds
To update the seeds in production use:
```
$ source .env
$ gigalixir remote_console
1> Path.join(["#{:code.priv_dir(:igwet)}", "repo", "seeds.exs"]) |> Code.eval_file
```
DANGER: Only do this once or you may blow away all your data.
