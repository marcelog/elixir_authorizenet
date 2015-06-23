defmodule AuthorizeNet.Helper.Http do
  require Logger

  def req(method, uri, body \\ [], headers \\ [], qs \\ %{}) do
    qs = URI.encode_query qs
    headers = [
      {'Content-Type', 'application/xml'},
      {'Accept', 'application/xml'}
    |headers]
    uri = to_char_list "#{uri}?#{qs}"
    body = format_xml(body) |> XmlBuilder.generate
    ret = :ibrowse.send_req(
      uri, headers, method, body, [
      {:response_format, :binary}, {:max_sessions, 50}, {:max_pipeline_size, 1},
      {:connect_timeout, 60000}, {:inactivity_timeout, 60000},
      {:stream_chunk_size, 10}, {:ssl_options, [{:verify, :verify_none}]}
    ])
    Logger.debug "Request: #{body}: #{inspect ret}"
    case ret do
      {:ok, status_code, retheaders, retbody} ->
        {status_code, _} = Integer.parse to_string(status_code)
        retheaders = Enum.reduce retheaders, %{}, fn({k, v}, acc) ->
          Map.put acc, String.downcase(to_string(k)), to_string(v)
        end
        {:ok, status_code, retheaders, retbody}
      _ -> ret
    end
  end

  defp format_xml(list) do
    format_xml list, []
  end

  defp format_xml([], acc) do
    Enum.reverse acc
  end

  defp format_xml([{k, v}|rest], acc) do
    v = if is_list(v) do
      format_xml v
    else
      v
    end
    format_xml rest, [
      {k, %{xmlns: "AnetApi/xml/v1/schema/AnetApiSchema.xsd"}, v}
      |acc
    ]
  end
end