import Config

config :fna_app, Fna.Repo,
  database: "fna_app_repo",
  username: "postgres",
  password: "postgres",
  pool_size: 10

config :logger,
  level: :info,
  backends: [:console],
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ]
