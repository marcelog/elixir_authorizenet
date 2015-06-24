:ok = Application.ensure_started :ranch
:ok = Application.ensure_started :cowlib
:ok = Application.ensure_started :cowboy

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
        Application.put_env :authorize_net, key, value
      end

      defp port() do
        Application.get_env :authorize_net, :test_server_port
      end

      defp path() do
        Application.get_env :authorize_net, :test_server_path
      end

      defp uri() do
        Application.get_env :authorize_net, :test_server_uri
      end

      defp set_test_uri() do
        path = "/#{:base64.encode :erlang.term_to_binary(:erlang.make_ref)}"
        uri = "http://127.0.0.1:#{port}#{path}"
        set_config :test_server_uri, uri
        set_config :test_server_path, path
        uri
      end

      defp start_server(fun) do
        set_test_uri
        serve :authnet_dummy, :http, "127.0.0.1", port, 1, [], [
          post(path, fn(bindings, headers, body, req, state) ->
            fun.(bindings, headers, body, req, state)
          end)
        ]
      end

      defp stop_server() do
        unserve :authnet_dummy
        :timer.sleep 100
      end
    end
  end
end
ExUnit.start()
