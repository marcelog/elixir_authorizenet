use Mix.Config

config :elixir_authorizenet,
  test_server_port: 10200,
  environment: :test,
  validation_mode: :none, # :test, :live, or :none
  login_id: "login_id",
  transaction_key: "transaction_key"
