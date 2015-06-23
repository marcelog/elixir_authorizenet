defmodule AuthorizeNet.Customer do
  use AuthorizeNet.Helper.XML
  alias AuthorizeNet, as: Main

  @type customer :: Keyword.t

  @spec get(Integer):: customer | no_return
  def get(id) do
    doc = Main.req :getCustomerProfileRequest, [customerProfileId: id]
    [description] = xml_value doc, "//description"
    [email] = xml_value doc, "//email"
    [merchantCustomerId] = xml_value doc, "//merchantCustomerId"
    [
      description: description,
      email: email,
      merchantCustomerId: merchantCustomerId,
      customerProfileId: id
    ]
  end

  @spec get_all():: [Integer]
  def get_all() do
    doc = Main.req :getCustomerProfileIdsRequest, []
    for id <- xml_value doc, "//numericString"  do
      {id, ""} = Integer.parse id
      id
    end
  end

  @spec update(Integer, String.t, String.t, String.t) :: customer | no_return
  def update(customer_id, id, description, email) do
    profile = [
      merchantCustomerId: id,
      description: description,
      email: email,
      customerProfileId: customer_id
    ]
    Main.req :updateCustomerProfileRequest, [profile: profile]
    profile
  end

  @spec create(String.t, String.t, String.t) :: customer | no_return
  def create(id, description, email) do
    profile = [
      merchantCustomerId: id,
      description: description,
      email: email
    ]
    doc = Main.req :createCustomerProfileRequest, [
      profile: profile,
      validationMode: "none"
    ]
     [id] = xml_value doc, "//customerProfileId"
     {id, ""} = Integer.parse id
     Keyword.put profile, :customerProfileId, id
  end

  @spec delete(Integer) :: :ok | no_return
  def delete(customer_id) do
    Main.req :deleteCustomerProfileRequest, [
      customerProfileId: to_string(customer_id)
    ]
    :ok
  end
end
