defmodule AuthorizeNet.Error.Connection do
  @moduledoc """
  Raised on connection errors, like network/dns issues, etc.
  """
  defexception message: "default message"
end