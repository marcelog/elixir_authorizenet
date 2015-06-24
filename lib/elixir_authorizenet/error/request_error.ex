defmodule AuthorizeNet.Error.Request do
  @moduledoc """
  Raised when Authorize.Net responded with a status code other than 200.
  """
  defexception message: "default message"
end