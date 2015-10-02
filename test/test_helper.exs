:ok = Application.ensure_started :ranch
:ok = Application.ensure_started :cowlib
:ok = Application.ensure_started :cowboy
:server_ports = :ets.new :server_ports, [
  :named_table, :public, {:read_concurrency, true},
  {:write_concurrency, false}
]
true = :ets.insert :server_ports, {:n, 10200}

defmodule AuthorizeNet.Test.Util do
  @moduledoc """
  Copyright 2015 Marcelo Gornstein <marcelog@gmail.com>

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  """
  require Logger
  use Servito

  defmacro __using__(_opts) do
    quote do
      import AuthorizeNet.Test.Util
      @before_compile AuthorizeNet.Test.Util
    end
  end

  defmacro serve_file(file) do
    quote [
      location: :keep,
      bind_quoted: [file: file]
    ] do
      ret 200, [], File.read!("test/resources/#{file}.xml")
    end
  end

  defmacro __before_compile__(_env) do
    quote [location: :keep] do
      require Logger

      defp validate(xml) do
        case :xmerl_xsd.process_validate 'test/resources/AnetApiSchema.xsd', xml do
          {:error, error} -> {:error, error}
          _ -> :ok
        end
      end

      defp set_config(key, value) do
        Application.put_env :elixir_authorizenet, key, value
      end

      defp set_test_uri() do
        port = :ets.update_counter :server_ports, :n, 1
        path = "/#{Base.encode16 :erlang.term_to_binary(:erlang.make_ref)}"
        uri = "http://127.0.0.1:#{port}#{path}"
        set_config :test_server_uri, uri
        set_config :test_server_path, path
        {path, uri, port}
      end

      defp start_server(fun) do
        {path, uri, port} = set_test_uri
        name = String.to_atom(
          :base64.encode :erlang.term_to_binary(:erlang.make_ref)
        )
        serve name, :http, "127.0.0.1", port, 1, [], [
          post(path, fn(bindings, headers, body, req, state) ->
            fun.(bindings, headers, body, req, state)
          end)
        ]
        name
      end

      defp stop_server(name) do
        unserve name
      end

      defp assert_fields(xml, msgs, fields) do
        Enum.reduce fields, msgs, fn({k, v}, acc) ->
          if xml_value(xml, "//#{k}") === [v] do
              acc
          else
            ["wrong #{k}"|acc]
          end
        end
      end
    end
  end
end
ExUnit.start()
