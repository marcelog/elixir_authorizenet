use Mix.Config

config :elixir_authorizenet,
  environment: :sandbox,
  validation_mode: :test, # :test, :live, or :none
  login_id: "77yyV5KGJf",
  transaction_key: "674VaGBSe5Eh58Sw"

import_config "#{Mix.env}.exs"
