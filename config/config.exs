use Mix.Config

config :elixir_authorizenet,
  environment: :sandbox,
  validation_mode: :test, # :test, :live, or :none
  login_id: "login_id",
  transaction_key: "transaction_key"

import_config "#{Mix.env}.exs"
