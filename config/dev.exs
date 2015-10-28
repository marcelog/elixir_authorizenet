use Mix.Config

config :elixir_authorizenet,
  environment: :production,
  validation_mode: :live, # :test, :live, or :none
  login_id: "login_id",
  transaction_key: "transaction_key"
