![github workflow](https://github.com/thiagoesteves/fna/workflows/Elixir%20CI/badge.svg)
[![Build Status](https://secure.travis-ci.org/thiagoesteves/fna.svg?branch=main)](http://travis-ci.org/thiagoesteves/fna)
[![Coverage Status](https://coveralls.io/repos/github/thiagoesteves/fna/badge.svg?branch=main)](https://coveralls.io/github/thiagoesteves/fna?branch=main)
[![Erlang/OTP Release](https://img.shields.io/badge/Erlang-OTP--23.0-green.svg)](https://github.com/erlang/otp/releases/tag/OTP-23.0)

# The Football News Aggregator application #

__Authors:__ Thiago Esteves ([`thiagocalori@gmail.com`](thiagocalori@gmail.com)).

## Introduction ##

The Football News Aggregator (FNA) is a home assignment test requested by Forza Football as part of the Technical Interview Process. All the special details about the application can be found in the doc folder under the name of "Forza Football home assignment.pdf" .

The initial Design for the servers will be as the picture below:

![FCA Design](/doc/fna_design.png)

The image below shows the supervision tree captured from the final application:

![Supervision Tree](/doc/supervision_tree.png)

### What can be improved ###

```
1- It is missing deploy files as docker, aws cloudFormation, etc;
2- It is possible to improve how both providers are connected by the collect_producer server, maybe each one could
have its own reference (ID) and the database could request only the one that timed out.
3- Implement some of the TODOs indicated in the code
4- Write some tests to check if the database is consistent with the data collected
5- Increase the number of unit test to achieve 100% coverage
6- Add configuration file for github actions
```

### Installing and running PostgreSQL locally (default) ###

For local installation:
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```
Once PostgreSQL is installed, we can create the user that will be used by Ecto:
```bash
sudo -u postgres psql
postgres=# CREATE USER postgres;
postgres=# ALTER USER postgres PASSWORD 'postgres';
postgres=# ALTER USER postgres WITH SUPERUSER;
```
Create the database using Ecto
```bash
mix ecto.drop -r Fna.Repo && mix ecto.create -r Fna.Repo && mix ecto.migrate -r Fna.Repo
```
After the application has created the Fna.Repo, you can access the database via this command
```bash
sudo -u postgres psql -W fna_app_repo # password is postgres
fna_app_repo=# SELECT matches.id AS id, home_team, away_team, created_at, kickoff_at, server_name FROM matches;
```

### Running PostgreSQL in a docker ###

Create and run a docker image with postgres:12.4-20.04_beta
```bash
docker run -d --name postgres-container -e TZ=UTC -p 30432:5432 -e POSTGRES_PASSWORD=postgres ubuntu/postgres:12.4-20.04_beta
```
Change the Ecto configuration at config/config.exs to use the port 30432
```elixir
config :fna_app, Fna.Repo,
  database: "fna_app_repo",
  username: "postgres",
  password: "postgres",
  port: "30432",
  pool_size: 10
```
Create the database using Ecto
```bash
mix ecto.drop -r Fna.Repo && mix ecto.create -r Fna.Repo && mix ecto.migrate -r Fna.Repo
```
After the application has created the Fna.Repo, you can access the database via this command
```bash
docker exec -it postgres-container /bin/bash
root@86f6777831fe:/# psql -U postgres -W fna_app_repo
fna_app_repo=# SELECT matches.id AS id, home_team, away_team, created_at, kickoff_at, server_name FROM matches;
```

PS: these informations can be checked at:
```
https://hub.docker.com/r/ubuntu/postgres: 
```
### Compiling and Running ###

To compile and run for your machine just call the following command in the CLI:

```bash
$ iex -S mix
```

### Testing and checking ###

Execute the following commands to get more information
```bash
$ mix test --cover
$ mix coveralls.html
```
