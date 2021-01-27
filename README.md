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

### Installing and running PostgreSQL ###

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
Create the databse using Ecto
```bash
mix ecto.drop -r Fna.Repo && mix ecto.create -r Fna.Repo && mix ecto.migrate -r Fna.Repo
```
After the application has created the Fna.Repo, you can access the database via this command
```bash
sudo -u postgres psql -W fna_app_repo # password is postgres
fna_app_repo=# SELECT matches.id AS id, home_team, away_team, created_at, kickoff_at, server_name FROM matches;
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