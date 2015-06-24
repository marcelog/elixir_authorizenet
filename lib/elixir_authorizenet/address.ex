defmodule AuthorizeNet.Address do
  @moduledoc """
  Address structure for billing and shipping.
  """
  use AuthorizeNet.Helper.XML
  defstruct address: nil,
    city: nil,
    state: nil,
    zip: nil,
    country: nil,
    phone: nil,
    fax: nil

  @type t :: %AuthorizeNet.Address{}

  @doc """
  Creates a new Address structure, used for billing and/or shipping.
  """
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
      phone: phone,
      fax: fax
    }
  end

  @doc """
  Renders the given address structure as a structure suitable to be rendered as
  xml.
  """
  @spec to_xml(AuthorizeNet.Address.t) :: Keyword.t
  def to_xml(address) do
    [
      address: address.address,
      city: address.city,
      state: address.state,
      zip: address.zip,
      country: address.country,
      phoneNumber: address.phone,
      faxNumber: address.fax
    ]
  end

  @doc """
  Builds an Address from an xmlElement record.
  """
  @spec from_xml(Record) :: AuthorizeNet.Address.t
  def from_xml(doc) do
    new(
      xml_one_value(doc, "//address"),
      xml_one_value(doc, "//city"),
      xml_one_value(doc, "//state"),
      xml_one_value(doc, "//zip"),
      xml_one_value(doc, "//country"),
      xml_one_value(doc, "//phoneNumber"),
      xml_one_value(doc, "//faxNumber")
    )
  end
end
