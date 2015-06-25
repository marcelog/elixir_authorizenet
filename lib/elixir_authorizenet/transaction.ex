defmodule AuthorizeNet.Transaction do
  @moduledoc """
  Transaction.

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
  alias AuthorizeNet, as: Main
  alias AuthorizeNet.TransactionResponse, as: Response
  alias AuthorizeNet.Card, as: Card
  alias AuthorizeNet.Address, as: Address

  @settings [
    partial_auth: "allowPartialAuth",
    duplicate_window: "duplicateWindow",
    email_customer: "emailCustomer"
  ]
  defstruct settings: %{},
    user_fields: %{},
    tax: nil,
    duty: nil,
    shipping_cost: nil,
    po: nil,
    order: nil,
    device_type: nil,
    market_type: nil,
    amount: 0,
    type: nil,
    payment_type: nil,
    opaque_data_descriptor: nil,
    opaque_data_value: nil,
    items: [],
    card: nil,
    employee_id: nil,
    customer_ip: nil,
    tax_exempt: nil,
    shipping_address: nil,
    billing_address: nil,
    customer_profile_id: nil,
    payment_profile_id: nil,
    shipping_address_id: nil,
    card_code: nil,
    ref_transaction_id: nil

  @type t :: Map
  @transaction_types [
    void: "voidTransaction",
    refund: "refundTransaction",
    auth_capture: "authCaptureTransaction",
    auth_only: "authOnlyTransaction",
    prior_auth_capture: "priorAuthCaptureTransaction",
    capture_only: "captureOnlyTransaction"
  ]

  @doc """
  Creates a new transaction.
  """
  @spec new(Float) :: AuthorizeNet.Transaction.t
  def new(amount) do
    %AuthorizeNet.Transaction{amount: amount}
  end

  @doc """
  "AUTH AND CAPTURE" transaction. See:
  https://support.authorize.net/authkb/index?page=content&id=A510
  """
  @spec auth_capture(AuthorizeNet.Transaction.t) :: AuthorizeNet.Transaction.t
  def auth_capture(transaction) do
    %AuthorizeNet.Transaction{transaction | type: :auth_capture}
  end

  @doc """
  "AUTH ONLY" transaction. See:
  https://support.authorize.net/authkb/index?page=content&id=A510
  """
  @spec auth_only(AuthorizeNet.Transaction.t) :: AuthorizeNet.Transaction.t
  def auth_only(transaction) do
    %AuthorizeNet.Transaction{transaction | type: :auth_only}
  end

  @doc """
  "CAPTURE ONLY" transaction. See:
  https://support.authorize.net/authkb/index?page=content&id=A510
  """
  @spec capture_only(AuthorizeNet.Transaction.t) :: AuthorizeNet.Transaction.t
  def capture_only(transaction) do
    %AuthorizeNet.Transaction{transaction | type: :capture_only}
  end

  @doc """
  "PRIOR AUTH CAPTURE" transaction. See:
  https://support.authorize.net/authkb/index?page=content&id=A510
  """
  @spec prior_auth_capture(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def prior_auth_capture(transaction) do
    %AuthorizeNet.Transaction{transaction | type: :prior_auth_capture}
  end

  @doc """
  Transaction ID of the original partial authorization transaction.
  Required only for refundTransaction, priorAuthCaptureTransaction,
  and voidTransaction. Do not include this field if you are providing
  splitTenderId
  """
  @spec ref_transaction_id(
    AuthorizeNet.Transaction.t, String.t
  ) :: AuthorizeNet.Transaction.t
  def ref_transaction_id(transaction, id) do
    %AuthorizeNet.Transaction{transaction |
      ref_transaction_id: id
    }
  end

  @doc """
  Adds shipping information.
  """
  @spec ship_to(
    AuthorizeNet.Transaction.t, AuthorizeNet.Address.t
  ) :: AuthorizeNet.Transaction.t
  def ship_to(transaction, address) do
    %AuthorizeNet.Transaction{transaction | shipping_address: address}
  end

  @doc """
  Adds billing information.
  """
  @spec bill_to(
    AuthorizeNet.Transaction.t, AuthorizeNet.Address.t
  ) :: AuthorizeNet.Transaction.t
  def bill_to(transaction, address) do
    %AuthorizeNet.Transaction{transaction | billing_address: address}
  end

  @doc """
  Set employeeId. Merchant-assigned employee ID.
  Required only if your payment processor is EVO.
  """
  @spec employee_id(
    AuthorizeNet.Transaction.t, Integer
  ) :: AuthorizeNet.Transaction.t
  def employee_id(transaction, employee_id) do
    %AuthorizeNet.Transaction{transaction | employee_id: employee_id}
  end

  @doc """
  Indicates exempted from tax.
  """
  @spec tax_exempt(AuthorizeNet.Transaction.t) :: AuthorizeNet.Transaction.t
  def tax_exempt(transaction) do
    %AuthorizeNet.Transaction{transaction | tax_exempt: true}
  end

  @doc """
  Indicates NOT exempted from tax.
  """
  @spec not_tax_exempt(AuthorizeNet.Transaction.t) :: AuthorizeNet.Transaction.t
  def not_tax_exempt(transaction) do
    %AuthorizeNet.Transaction{transaction | tax_exempt: false}
  end

  @doc """
  IP address of customer initiating the transaction. If this value is not
  passed, it will default to 255.255.255.255.
  Required only when the merchant is using customer IP based AFDS filters.
  """
  @spec customer_ip(
    AuthorizeNet.Transaction.t, String.t
  ) :: AuthorizeNet.Transaction.t
  def customer_ip(transaction, ip) do
    %AuthorizeNet.Transaction{transaction | customer_ip: ip}
  end

  @doc """
  Pays this transaction with credit card.
  """
  @spec pay_with_card(
    AuthorizeNet.Transaction.t, AuthorizeNet.Card.t
  ) :: AuthorizeNet.Transaction.t
  def pay_with_card(transaction, card) do
    %AuthorizeNet.Transaction{transaction |
      payment_type: :card,
      card: card
    }
  end

  @doc """
  Pay with a customer profile ID.
  """
  @spec pay_with_customer_profile(
    AuthorizeNet.Card.t, Integer, Integer, Integer | nil, String.t | nil
  ) :: AuthorizeNet.Card.t
  def pay_with_customer_profile(
    transaction, customer_profile_id, payment_profile_id,
    shipping_address_id \\ nil, card_code \\ nil
  ) do
    %AuthorizeNet.Transaction{transaction |
      payment_type: :customer_profile,
      card_code: card_code,
      customer_profile_id: customer_profile_id,
      payment_profile_id: payment_profile_id,
      shipping_address_id: shipping_address_id
    }
  end

  @doc """
  Pays this transaction with Apple Pay.
  """
  @spec pay_with_apple_pay(
    AuthorizeNet.Transaction.t, String.t
  ) :: AuthorizeNet.Transaction.t
  def pay_with_apple_pay(transaction, data) do
    %AuthorizeNet.Transaction{transaction | payment_type: :apple_pay} |>
    opaque_data_descriptor("COMMON.APPLE.INAPP.PAYMENT") |>
    opaque_data_value(data)
  end

  @doc """
  128 characters. Meta data used to specify how the request
  should be processed. The value of dataDescriptor is based on the source of
  the opaqueData dataValue.
  """
  @spec opaque_data_descriptor(
    AuthorizeNet.Transaction.t, String.t
  ) :: AuthorizeNet.Transaction.t
  def opaque_data_descriptor(transaction, descriptor) do
    %AuthorizeNet.Transaction{
      transaction | opaque_data_descriptor: descriptor
    }
  end

  @doc """
  8192 characters Base-64 encoded data that contains encrypted payment data.
  The payment gateway expects the encrypted payment data and meta data for
  the encryption keys.
  """
  @spec opaque_data_descriptor(
    AuthorizeNet.Transaction.t, String.t
  ) :: AuthorizeNet.Transaction.t
  def opaque_data_value(transaction, value) do
    %AuthorizeNet.Transaction{
      transaction | opaque_data_value: value
    }
  end

  @doc """
  The merchant-assigned purchase order number.
  Purchase order number must be created dynamically on the merchant's
  server or provided on a per-transaction basis. The payment gateway does not
  perform this function.
  """
  @spec po_number(
    AuthorizeNet.Transaction.t, String.t
  ) :: AuthorizeNet.Transaction.t
  def po_number(transaction, po_number) do
    %AuthorizeNet.Transaction{transaction | po: po_number}
  end

  @doc """
  Add items to the order.
  """
  @spec add_item(
    AuthorizeNet.Transaction.t, String.t, String.t, String.t, Integer, Float
  ) :: AuthorizeNet.Transaction.t
  def add_item(transaction, id, name, description, qty, unit_price) do
    items = [%{
      id: id,
      name: name,
      description: description,
      qty: qty,
      unit_price: unit_price
    }|transaction.items]
    %AuthorizeNet.Transaction{transaction | items: items}
  end

  @doc """
  Runs the transaction.
  """
  def run(transaction) do
    doc = try do
      Main.req :createTransactionRequest, [
        transactionRequest: to_xml(transaction)
      ]
    rescue
      e in AuthorizeNet.Error.Operation ->
        {_codes, doc} = e.message
        doc
    end
    Response.new doc
  end

  @doc """
  Sets market type: 0 - ecommerce.
  This is part of the "retail" field, that needs device type and also market
  type.
  """
  @spec market_ecommerce(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def market_ecommerce(transaction) do
    set_market transaction, 0
  end

  @doc """
  Sets market type: 1 - motto.
  This is part of the "retail" field, that needs device type and also market
  type.
  """
  @spec market_moto(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def market_moto(transaction) do
    set_market transaction, 1
  end

  @doc """
  Sets market type: 2 - retail.
  This is part of the "retail" field, that needs device type and also market
  type.
  """
  @spec market_retail(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def market_retail(transaction) do
    set_market transaction, 2
  end

  @doc """
  Sets device type: 1 - Unknown.
  This is part of the "retail" field, that needs device type and also market
  type.
  """
  @spec device_unknown(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def device_unknown(transaction) do
    set_device transaction, 1
  end

  @doc """
  Sets device type: 2 - Unattended Terminal.
  This is part of the "retail" field, that needs device type and also market
  type.
  """
  @spec device_unattended_terminal(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def device_unattended_terminal(transaction) do
    set_device transaction, 2
  end

  @doc """
  Sets device type: 3 - Self Service Terminal.
  This is part of the "retail" field, that needs device type and also market
  type.
  """
  @spec device_self_service_terminal(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def device_self_service_terminal(transaction) do
    set_device transaction, 3
  end

  @doc """
  Sets device type: 4 - Electronic Cash Register.
  This is part of the "retail" field, that needs device type and also market
  type.
  """
  @spec device_electronic_cash_register(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def device_electronic_cash_register(transaction) do
    set_device transaction, 4
  end

  @doc """
  Sets device type: 5 - Personal Computer- Based Terminal.
  This is part of the "retail" field, that needs device type and also market
  type.
  """
  @spec device_personal_computer(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def device_personal_computer(transaction) do
    set_device transaction, 5
  end

  @doc """
  Sets device type: 6 - AirPay.
  This is part of the "retail" field, that needs device type and also market
  type.
  """
  @spec device_air_pay(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def device_air_pay(transaction) do
    set_device transaction, 6
  end

  @doc """
  Sets device type: 7 - Wireless POS.
  This is part of the "retail" field, that needs device type and also market
  type.
  """
  @spec device_wireless_pos(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def device_wireless_pos(transaction) do
    set_device transaction, 7
  end

  @doc """
  Sets device type: 8 - Website.
  This is part of the "retail" field, that needs device type and also market
  type.
  """
  @spec device_website(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def device_website(transaction) do
    set_device transaction, 8
  end

  @doc """
  Sets device type: 9 - Dial Terminal.
  This is part of the "retail" field, that needs device type and also market
  type.
  """
  @spec device_dial_terminal(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def device_dial_terminal(transaction) do
    set_device transaction, 9
  end

  @doc """
  Sets device type: 10 - Virtual Terminal.
  This is part of the "retail" field, that needs device type and also market
  type.
  """
  @spec device_virtual_terminal(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def device_virtual_terminal(transaction) do
    set_device transaction, 10
  end

  @doc """
  Set order information.
  """
  @spec order(
    AuthorizeNet.Transaction.t, String.t, String.t
  ) :: AuthorizeNet.Transaction.t
  def order(transaction, invoice_number, description) do
    %AuthorizeNet.Transaction{transaction | order: %{
      invoice_number: invoice_number,
      description: description
    }}
  end

  @doc """
  Set arbitrary user fields.
  """
  @spec user_fields(
    AuthorizeNet.Transaction.t, Map
  ) :: AuthorizeNet.Transaction.t
  def user_fields(transaction, fields) do
    %AuthorizeNet.Transaction{transaction | user_fields: fields}
  end

  @doc """
  Set tax information.
  """
  @spec tax(
    AuthorizeNet.Transaction.t, String.t, String.t, Float
  ) :: AuthorizeNet.Transaction.t
  def tax(transaction, name, description, amount) do
    %AuthorizeNet.Transaction{transaction | tax: %{
      name: name,
      description: description,
      amount: amount
    }}
  end

  @doc """
  Set duty information.
  """
  @spec duty(
    AuthorizeNet.Transaction.t, String.t, String.t, Float
  ) :: AuthorizeNet.Transaction.t
  def duty(transaction, name, description, amount) do
    %AuthorizeNet.Transaction{transaction | duty: %{
      name: name,
      description: description,
      amount: amount
    }}
  end

  @doc """
  Set shipping cost information.
  """
  @spec shipping_cost(
    AuthorizeNet.Transaction.t, String.t, String.t, Float
  ) :: AuthorizeNet.Transaction.t
  def shipping_cost(transaction, name, description, amount) do
    %AuthorizeNet.Transaction{transaction | shipping_cost: %{
      name: name,
      description: description,
      amount: amount
    }}
  end

  @doc """
  Enable transaction setting "testRequest".
  """
  @spec enable_test_request(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def enable_test_request(transaction) do
    enable_setting transaction, "testRequest"
  end

  @doc """
  Disable transaction setting "testRequest".
  """
  @spec disable_test_request(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def disable_test_request(transaction) do
    disable_setting transaction, "testRequest"
  end

  @doc """
  Enable transaction setting "recurringBilling".
  """
  @spec enable_recurring_billing(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def enable_recurring_billing(transaction) do
    enable_setting transaction, "recurringBilling"
  end

  @doc """
  Disable transaction setting "recurringBilling".
  """
  @spec disable_recurring_billing(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def disable_recurring_billing(transaction) do
    disable_setting transaction, "recurringBilling"
  end

  @doc """
  Enable transaction setting "emailCustomer".
  """
  @spec enable_email_customer(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def enable_email_customer(transaction) do
    enable_setting transaction, "emailCustomer"
  end

  @doc """
  Disable transaction setting "emailCustomer".
  """
  @spec disable_email_customer(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def disable_email_customer(transaction) do
    disable_setting transaction, "emailCustomer"
  end

  @doc """
  Enable transaction setting "allowPartialAuth".
  """
  @spec enable_partial_auth(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def enable_partial_auth(transaction) do
    enable_setting transaction, "allowPartialAuth"
  end

  @doc """
  Disable transaction setting "allowPartialAuth".
  """
  @spec disable_partial_auth(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def disable_partial_auth(transaction) do
    disable_setting transaction, "allowPartialAuth"
  end

  @doc """
  Enable transaction setting "duplicateWindow".
  """
  @spec enable_duplicate_window(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def enable_duplicate_window(transaction) do
    enable_setting transaction, "duplicateWindow"
  end

  @doc """
  Disable transaction setting "duplicateWindow".
  """
  @spec disable_duplicate_window(
    AuthorizeNet.Transaction.t
  ) :: AuthorizeNet.Transaction.t
  def disable_duplicate_window(transaction) do
    disable_setting transaction, "duplicateWindow"
  end

  @doc """
  Renders the given transaction structure as a structure suitable to be
  rendered as xml.
  """
  @spec to_xml(AuthorizeNet.Transaction.t) :: Keyword.t
  def to_xml(transaction) do
    [
      transactionType: @transaction_types[transaction.type],
      amount: to_string(transaction.amount),
      payment: (
        case transaction.payment_type do
          :apple_pay -> [
            opaqueData: [
              dataDescriptor: transaction.opaque_data_descriptor,
              dataValue: transaction.opaque_data_value
            ]
          ]
          :card -> Card.to_xml(transaction.card)
          :customer_profile -> nil
        end
      ),
      profile: (if transaction.payment_type !== :customer_profile do
        nil
      else
        [
          customerProfileId: transaction.customer_profile_id,
          paymentProfile: [
            paymentProfileId: transaction.payment_profile_id,
            cardCode: transaction.card_code
          ],
          shippingProfileId: transaction.shipping_address_id
        ]
      end),
      refTransId: transaction.ref_transaction_id,
      order: (if is_nil transaction.order do
        nil
      else
        [
          invoiceNumber: transaction.order.invoice_number,
          description: transaction.order.description
        ]
      end),
      lineItems: for i <- transaction.items do
        {:lineItem, [
          itemId: i.id,
          name: i.name,
          description: i.description,
          quantity: i.qty,
          unitPrice: to_string(i.unit_price)
        ]}
      end,
      tax: (if is_nil transaction.tax do
        nil
      else
        [
          amount: to_string(transaction.tax.amount),
          name: transaction.tax.description,
          description: transaction.tax.description
        ]
      end),
      duty: (if is_nil transaction.duty do
        nil
      else
        [
          amount: to_string(transaction.duty.amount),
          name: transaction.duty.description,
          description: transaction.duty.description
        ]
      end),
      shipping: (if is_nil transaction.shipping_cost do
        nil
      else
        [
          amount: to_string(transaction.shipping_cost.amount),
          name: transaction.shipping_cost.description,
          description: transaction.shipping_cost.description
        ]
      end),
      taxExempt: transaction.tax_exempt,
      poNumber: transaction.po,
      billTo: (if is_nil transaction.billing_address do
        nil
      else
        Address.to_xml transaction.billing_address
      end),
      shipTo: (if is_nil transaction.shipping_address do
        nil
      else
        Address.to_xml(transaction.shipping_address) |>
        Keyword.delete(:phoneNumber) |>
        Keyword.delete(:faxNumber)
      end),
      customerIP: transaction.customer_ip,
      retail: (
        if((is_nil transaction.market_type) or
          (is_nil transaction.device_type)) do
          nil
        else
          [
            marketType: transaction.market_type,
            deviceType: transaction.device_type
          ]
      end),
      employeeId: to_string(transaction.employee_id),
      transactionSettings: for {k, v} <- transaction.settings do
        {:setting, [settingName: k, settingValue: to_string(v)]}
      end,
      userFields: for {k, v} <- transaction.user_fields do
        {:userField, [name: k, value: v]}
      end
    ]
  end

  defp enable_setting(transaction, key) do
    set_setting transaction, key, true
  end

  defp disable_setting(transaction, key) do
    set_setting transaction, key, false
  end

  defp set_setting(transaction, key, value) do
    settings = Map.put transaction.settings, key, value
    %AuthorizeNet.Transaction{transaction | settings: settings}
  end

  defp set_market(transaction, market) do
    %AuthorizeNet.Transaction{transaction | market_type: market}
  end

  defp set_device(transaction, device) do
    %AuthorizeNet.Transaction{transaction | device_type: device}
  end
end