defmodule AuthorizeNet.Address do
  @moduledoc """
  Address structure for billing and shipping.

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
  use AuthorizeNet.Helper.XML
  defstruct address: nil,
    city: nil,
    state: nil,
    zip: nil,
    country: nil,
    phone: nil,
    fax: nil,
    id: nil,
    first_name: nil,
    last_name: nil,
    company: nil,
    customer_id: nil

  @type t :: %AuthorizeNet.Address{}

  @doc """
  Creates a new Address structure, used for billing and/or shipping.
  """
  @spec new(
    String.t, String.t, String.t, String.t, String.t, String.t, String.t,
    String.t, String.t, String.t
  ) :: AuthorizeNet.Address.t
  def new(
    first_name, last_name, company, street_address, city, state, zip,
    country, phone, fax
  ) do
    %AuthorizeNet.Address{
      first_name: first_name,
      last_name: last_name,
      company: company,
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
      firstName: address.first_name,
      lastName: address.last_name,
      company: address.company,
      address: address.address,
      city: address.city,
      state: address.state,
      zip: address.zip,
      country: address.country,
      phoneNumber: address.phone,
      faxNumber: address.fax,
      customerAddressId: address.id
    ]
  end

  @doc """
  Builds an Address from an xmlElement record.
  """
  @spec from_xml(Record, Integer) :: AuthorizeNet.Address.t
  def from_xml(doc, customer_id \\ nil) do
    id = case xml_one_value(doc, "//customerAddressId") do
      nil -> nil
      id ->
       {id, ""} = Integer.parse id
       id
    end
    profile = new(
      xml_one_value(doc, "//firstName"),
      xml_one_value(doc, "//lastName"),
      xml_one_value(doc, "//company"),
      xml_one_value(doc, "//address"),
      xml_one_value(doc, "//city"),
      xml_one_value(doc, "//state"),
      xml_one_value(doc, "//zip"),
      xml_one_value(doc, "//country"),
      xml_one_value(doc, "//phoneNumber"),
      xml_one_value(doc, "//faxNumber")
    )
    %AuthorizeNet.Address{profile | id: id, customer_id: customer_id}
  end
end
