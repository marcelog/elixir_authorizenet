defmodule AuthorizeNet.PaymentProfile do
  @moduledoc """
  Handles customer payment profiles (http://developer.authorize.net/api/reference/index.html#manage-customer-profiles-create-customer-payment-profile).
  """
  use AuthorizeNet.Helper.XML
  alias AuthorizeNet.Address, as: Address
  alias AuthorizeNet.Card, as: Card
  alias AuthorizeNet.BankAccount, as: BankAccount
  alias AuthorizeNet, as: Main

  defstruct first_name: nil,
    last_name: nil,
    company: nil,
    address: nil,
    customer_id: nil,
    type: nil,
    payment_type: nil,
    profile_id: nil

  @type t :: %AuthorizeNet.PaymentProfile{}
  @type payment_type :: BankAccount.t | Card.t

  @doc """
  Creates a payment profile for an "invidual".
  """
  @spec create_individual(
    Integer, String.t, String.t, String.t, Address.t,
    AuthorizeNet.PaymentProfile.payment_type
  ) :: AuthorizeNet.PaymentProfile.t | no_return
  def create_individual(
    customer_id, first_name, last_name, company, address, payment_type
  ) do
    create(
      :individual, customer_id, nil, first_name, last_name,
      company, address, payment_type
    )
  end

  @doc """
  Creates a payment profile for a "business".
  """
  @spec create_business(
    Integer, String.t, String.t, String.t, Address.t,
    AuthorizeNet.PaymentProfile.payment_type
  )  :: AuthorizeNet.PaymentProfile.t | no_return
  def create_business(
    customer_id, first_name, last_name, company, address, payment_type
  ) do
    create(
      :business, customer_id, nil, first_name, last_name,
      company, address, payment_type
    )
  end

  @spec create(
    String.t, Integer, Integer, String.t, String.t, Address.t,
    Address.t, AuthorizeNet.PaymentProfile.payment_type
  ) :: AuthorizeNet.PaymentProfile.t | no_return
  defp create(
    type, customer_id, profile_id, first_name, last_name,
    company, address, payment_type
  ) do
    profile = new(
      type, customer_id, profile_id, first_name, last_name,
      company, address, payment_type
    )
    xml = to_xml profile
    doc = Main.req :createCustomerPaymentProfileRequest, xml
    [profile_id] = xml_value doc, "//customerPaymentProfileId"
    {profile_id, ""} = Integer.parse profile_id
    %AuthorizeNet.PaymentProfile{profile | profile_id: profile_id}
  end

  @spec create(
    String.t, Integer, Integer, String.t, String.t, Address.t,
    Address.t, AuthorizeNet.PaymentProfile.payment_type
  ) :: AuthorizeNet.PaymentProfile.t | no_return
  defp new(
    type, customer_id, profile_id, first_name, last_name, company,
    address, payment_type
  ) do
    case payment_type do
      %BankAccount{} -> :ok
      %Card{} -> :ok
      _ -> raise ArgumentError, "Only AuthorizeNet.BankAccount and " <>
        "AuthorizeNet.Card are supported as a payment_type"
    end
    %AuthorizeNet.PaymentProfile{
      type: type,
      first_name: first_name,
      last_name: last_name,
      company: company,
      address: address,
      customer_id: customer_id,
      payment_type: payment_type,
      profile_id: profile_id
    }
  end

  defp to_xml(profile) do
    bill_to = [
      firstName: profile.first_name,
      lastName: profile.last_name,
      company: profile.company,
    ] ++ Address.to_xml(profile.address)
    payment = case profile.payment_type do
      %BankAccount{} -> BankAccount.to_xml profile.payment_type
      %Card{} -> Card.to_xml profile.payment_type
    end
    [
      customerProfileId: profile.customer_id,
      paymentProfile: [
        customerType: profile.type,
        billTo: bill_to,
        payment: payment
      ],
      validationMode: Main.validation_mode
    ]
  end

  @doc """
  Builds an PaymentProfile from an xmlElement record.
  """
  @spec from_xml(Record, Integer) :: AuthorizeNet.PaymentProfile.t
  def from_xml(doc, customer_id \\ nil) do
    payment = case xml_find doc, "//creditCard" do
      [] -> BankAccount.from_xml doc
      _ -> Card.from_xml doc
    end
    address = case xml_find doc, "//billTo" do
      [] -> nil
      _ -> Address.from_xml doc
    end
    new(
      xml_one_value(doc, "//customerType"),
      customer_id,
      xml_one_value(doc, "//customerPaymentProfileId"),
      xml_one_value(doc, "//firstName"),
      xml_one_value(doc, "//lastName"),
      xml_one_value(doc, "//company"),
      address,
      payment
    )
  end
end