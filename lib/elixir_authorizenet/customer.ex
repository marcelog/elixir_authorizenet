defmodule AuthorizeNet.Customer do
  @moduledoc """
  Handles customer profiles (http://developer.authorize.net/api/reference/index.html#manage-customer-profiles).

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
  alias AuthorizeNet, as: Main
  alias AuthorizeNet.PaymentProfile, as: PaymentProfile
  defstruct description: nil,
    email: nil,
    id: nil,
    profile_id: nil,
    payment_profiles: []

  @type t :: %AuthorizeNet.Customer{}

  @doc """
  Returns a customer profile by customer profile ID. See:
  http://developer.authorize.net/api/reference/index.html#manage-customer-profiles-get-customer-profile
  """
  @spec get(Integer):: AuthorizeNet.Customer.t | no_return
  def get(profile_id) do
    doc = Main.req :getCustomerProfileRequest, [customerProfileId: profile_id]
    from_xml doc
  end

  @doc """
  Returns all customer profile IDs known by Authorize.Net. See:
  http://developer.authorize.net/api/reference/index.html#manage-customer-profiles-get-customer-profile-ids
  """
  @spec get_all():: [Integer] | no_return
  def get_all() do
    doc = Main.req :getCustomerProfileIdsRequest, []
    for profile_id <- xml_value doc, "//numericString"  do
      {profile_id, ""} = Integer.parse profile_id
      profile_id
    end
  end

  @doc """
  Updates a customer profile given a valid customer profile ID. See:
  http://developer.authorize.net/api/reference/index.html#manage-customer-profiles-update-customer-profile
  """
  @spec update(
    Integer, String.t, String.t, String.t
  ) :: AuthorizeNet.Customer.t | no_return
  def update(profile_id, id, description, email) do
    profile = [
      merchantCustomerId: id,
      description: description,
      email: email,
      customerProfileId: profile_id
    ]
    Main.req :updateCustomerProfileRequest, [profile: profile]
    new id, profile_id, description, email
  end

  @doc """
  Creates a customer profile. See:
  http://developer.authorize.net/api/reference/index.html#manage-customer-profiles-create-customer-profile
  """
  @spec create(
    String.t, String.t, String.t
  ) :: AuthorizeNet.Customer.t | no_return
  def create(id, description, email) do
    profile = new id, nil, description, email
    profile_xml = to_xml profile
    doc = Main.req :createCustomerProfileRequest, [
      profile: profile_xml,
      validationMode: "none"
    ]
   [profile_id] = xml_value doc, "//customerProfileId"
   {profile_id, ""} = Integer.parse profile_id
   %AuthorizeNet.Customer{profile | profile_id: profile_id}
  end

  @doc """
  Deletes a customer profile by customer profile ID. See:
  http://developer.authorize.net/api/reference/index.html#manage-customer-profiles-delete-customer-profile
  """
  @spec delete(Integer) :: :ok | no_return
  def delete(customer_id) do
    Main.req :deleteCustomerProfileRequest, [
      customerProfileId: to_string(customer_id)
    ]
    :ok
  end

  @spec new(
    String.t, Integer, String.t, String.t, [PaymentProfile.t]
  ) :: AuthorizeNet.Customer.t | no_return
  defp new(id, profile_id, description, email, payment_profiles \\ []) do
    %AuthorizeNet.Customer{
      id: id,
      description: description,
      email: email,
      profile_id: profile_id,
      payment_profiles: payment_profiles
    }
  end

  defp to_xml(customer) do
    [
      merchantCustomerId: customer.id,
      description: customer.description,
      email: customer.email,
      customerProfileId: customer.profile_id
    ]
  end

  @doc """
  Builds an Customer from an xmlElement record.
  """
  @spec from_xml(Record) :: AuthorizeNet.Customer.t
  def from_xml(doc) do
    profile_id = case xml_one_value doc, "//customerProfileId" do
      nil -> nil
      profile_id ->
       {profile_id, ""} = Integer.parse profile_id
       profile_id
    end
    payment_profiles = for p <- xml_find(doc, "//paymentProfiles") do
      PaymentProfile.from_xml p, profile_id
    end
    new(
      xml_one_value(doc, "//merchantCustomerId"),
      profile_id,
      xml_one_value(doc, "//description"),
      xml_one_value(doc, "//email"),
      payment_profiles
    )
  end
end
