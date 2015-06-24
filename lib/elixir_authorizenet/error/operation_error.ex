defmodule AuthorizeNet.Error.Operation do
  @moduledoc """
  Raised when Authorize.Net didn't like the request (transaction declined,
  duplicated customer information, etc).
  """
  defexception message: "default message"
end