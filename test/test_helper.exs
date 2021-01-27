Application.load(:fna_app)

for app <- Application.spec(:fna_app,:applications) do
  Application.ensure_all_started(app)
end

ExUnit.start()
