defmodule AuthorizeNet.Customer do
  use AuthorizeNet.Helper.XML
  alias AuthorizeNet, as: Main

  @spec get(Integer):: Keyword.t
  def get(id) do
    id = to_string id
    doc = Main.req :getCustomerProfileRequest, [customerProfileId: id]
    [description] = xml_value doc, "//description"
    [email] = xml_value doc, "//email"
    [merchantCustomerId] = xml_value doc, "//merchantCustomerId"
    [
      description: description,
      email: email,
      merchantCustomerId: merchantCustomerId
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

  @spec update(Integer, String.t, String.t, String.t) :: :ok
  def update(customer_id, id, description, email) do
    Main.req :updateCustomerProfileRequest, [
      profile: [
        merchantCustomerId: id,
        description: description,
        email: email,
        customerProfileId: to_string(customer_id)
      ]
    ]
    :ok
  end

  @spec create(String.t, String.t, String.t) :: Integer
  def create(id, description, email) do
    doc = Main.req :createCustomerProfileRequest, [
      profile: [
        merchantCustomerId: id,
        description: description,
        email: email
      ],
      validationMode: "none"
    ]
     [id] = xml_value doc, "//customerProfileId"
     {id, ""} = Integer.parse id
     id
  end

  @spec delete(Integer) :: :ok
  def delete(customer_id) do
    Main.req :deleteCustomerProfileRequest, [
      customerProfileId: to_string(customer_id)
    ]
    :ok
  end
end
