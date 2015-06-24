defmodule AuthorizeNet.Address do
  @moduledoc """
  Handles addresses (for billing and shipping).
  """
  defstruct address: nil,
    city: nil,
    state: nil,
    zip: nil,
    country: nil,
    phoneNumber: nil,
    faxNumber: nil

  @type t :: %AuthorizeNet.Address{}

  @spec new(
    String.t, String.t, String.t, String.t, String.t, String.t, String.t
  ) :: AuthorizeNet.Address.t
  def new(street_address, city, state, zip, country, phone, fax) do
    %AuthorizeNet.Address{
      address: street_address,
      city: city,
      state: state,
      zip: zip,
      country: country,
      phoneNumber: phone,
      faxNumber: fax
    }
  end
end
