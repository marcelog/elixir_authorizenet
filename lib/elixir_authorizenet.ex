defmodule AuthorizeNet do
  use AuthorizeNet.Helper.XML
  alias AuthorizeNet.Helper.Http, as: Http
  alias AuthorizeNet.Error.Connection, as: RequestError
  alias AuthorizeNet.Error.Connection, as: ConnectionError
  alias AuthorizeNet.Error.Operation, as: OperationError
  require Logger

  @uris sandbox: "https://apitest.authorize.net/xml/v1/request.api",
    production: "https://api.authorize.net/xml/v1/request.api"

  def req(requestType, parameters) do
    body = [{requestType, [{:merchantAuthentication, auth}|parameters]}]
    case Http.req :post, uri, body do
      {:ok, 200, _headers, <<0xEF, 0xBB, 0xBF, body :: binary>>} ->
        {doc, _} = Exmerl.from_string body
        [result] = xml_value doc, "//messages/resultCode"
        if result === "Error" do
          codes = xml_value doc, "//code"
          texts = xml_value doc, "//text"
          raise OperationError, message: Enum.zip(codes, texts)
        end
        doc
      {:ok, status, headers, body} ->
        raise RequestError, message: {status, headers, body}
      {:error, error} ->
        raise ConnectionError, message: error
    end
  end

  def validation_mode() do
    case config :validation_mode do
      :live -> "liveMode"
      :test -> "testMode"
      :none -> "none"
    end
  end

  defp auth() do
    [name: login_id, transactionKey: transaction_key]
  end

  defp login_id() do
    config :login_id
  end

  defp transaction_key() do
    config :transaction_key
  end

  defp uri() do
    @uris[config(:environment)]
  end

  defp config(key) do
    Application.get_env :authorize_net, key
  end
end
