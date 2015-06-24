defmodule AuthorizeNet.Customer do
  @moduledoc """
  Handles customer profiles (http://developer.authorize.net/api/reference/index.html#manage-customer-profiles).
  """
  use AuthorizeNet.Helper.XML
  alias AuthorizeNet, as: Main
  defstruct description: nil,
    email: nil,
    id: nil,
    profile_id: nil

  @type t :: %AuthorizeNet.Customer{}

  @doc """
  Returns a customer profile by customer profile ID.
  """
  @spec get(Integer):: AuthorizeNet.Customer.t | no_return
  def get(profile_id) do
    doc = Main.req :getCustomerProfileRequest, [customerProfileId: profile_id]
    from_xml doc
  end

  @doc """
  Returns all customer profile IDs known by Authorize.Net.
  """
  @spec get_all():: [Integer]
  def get_all() do
    doc = Main.req :getCustomerProfileIdsRequest, []
    for profile_id <- xml_value doc, "//numericString"  do
      {profile_id, ""} = Integer.parse profile_id
      profile_id
    end
  end

  @doc """
  Updates a customer profile given a valid customer profile ID.
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
  Creates a customer profile.
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
  Deletes a customer profile by customer profile ID.
  """
  @spec delete(Integer) :: :ok | no_return
  def delete(customer_id) do
    Main.req :deleteCustomerProfileRequest, [
      customerProfileId: to_string(customer_id)
    ]
    :ok
  end

  @spec new(
    String.t, Integer, String.t, String.t
  ) :: AuthorizeNet.Customer.t
  defp new(id, profile_id, description, email) do
    %AuthorizeNet.Customer{
      id: id,
      description: description,
      email: email,
      profile_id: profile_id
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
  Builds an Address from an xmlElement record.
  """
  @spec from_xml(Record) :: AuthorizeNet.Customer.t
  def from_xml(doc) do
    profile_id = case xml_one_value doc, "//customerProfileId" do
      nil -> nil
      profile_id ->
       {profile_id, ""} = Integer.parse profile_id
       profile_id
    end
    new(
      xml_one_value(doc, "//merchantCustomerId"),
      profile_id,
      xml_one_value(doc, "//description"),
      xml_one_value(doc, "//email")
    )
  end
end
