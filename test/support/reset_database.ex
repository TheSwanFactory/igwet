#gigalixir ps:remote_console

Ecto.Migrator.run(Igwet.Repo, Application.app_dir(:igwet, "priv/repo/migrations"), :down, [all: true])
Ecto.Migrator.run(Igwet.Repo, Application.app_dir(:igwet, "priv/repo/migrations"), :up, [all: true])
seed_script = Path.join(["#{:code.priv_dir(:igwet)}", "repo", "seeds.exs"])
Code.eval_file(seed_script)
