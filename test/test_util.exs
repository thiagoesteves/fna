defmodule TestUtil do
  use ExUnit.Case
  doctest Fna.Application

  def default_providers, do: 2
  def default_timeout, do: 1000
  def matchbeam_url, do: 'http://forzaassignment.forzafootball.com:8080/feed/matchbeam'
  def matchbeam_sample_match, do: 
  "{ \"matches\": [
    {
      \"teams\": \"Arsenal - Chelsea FC\",
      \"kickoff_at\": 1543741200,
      \"created_at\": \"2018-12-19T09:00:00Z\"
    }
  ]}"

  def fastball_sample_match, 
  do: "{ \"matches\": [
    {
      \"home_team\": \"Arsenal\",
      \"away_team\": \"Chelsea FC\",
      \"kickoff_at\": 1543741200,
      \"created_at\": \"2018-12-19T09:00:00Z\"
    }
  ]}"
end
