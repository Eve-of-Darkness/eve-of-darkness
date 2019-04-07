{:ok, _} = Application.ensure_all_started(:ex_machina)
Logger.configure(level: :warn)
ExUnit.start()
