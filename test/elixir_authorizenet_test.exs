defmodule AuthorizeNetTest do
  @moduledoc """
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
  use ExUnit.Case, async: true
  use Servito
  use AuthorizeNet.Test.Util
  use AuthorizeNet.Helper.XML
  require Logger

  setup do
    :ok
  end

  test "can raise connection error on network issues" do
    assert_raise AuthorizeNet.Error.Connection, &AuthorizeNet.Customer.get_all/0
  end

  test "can raise request error on server issues" do
    name = start_server fn(_bindings, _headers, _body, req, state) ->
      ret 404, [], "blah"
    end
    assert_raise AuthorizeNet.Error.Connection, &AuthorizeNet.Customer.get_all/0
    stop_server name
  end

  test "can raise operation error on bad request" do
    name = start_server fn(_bindings, _headers, _body, req, state) ->
      serve_file "bad_auth"
    end
    assert_raise AuthorizeNet.Error.Operation, &AuthorizeNet.Customer.get_all/0
    stop_server name
  end

  test "can send credentials" do
    request_assert "customer_profiles_get_all", "getCustomerProfileIdsRequest",
      fn() -> AuthorizeNet.Customer.get_all end,
      fn(body, msgs) ->
        msgs = if xml_find(body, "//merchantAuthentication") === [] do
          ["missing auth section"|msgs]
        else
          msgs
        end
        assert_fields body, msgs, [
          {"name", "login_id"},
          {"transactionKey", "transaction_key"}
        ]
      end,
      fn(result) -> assert [35934704] === result end
  end

  test "can get all customer profiles" do
    request_assert "customer_profiles_get_all", "getCustomerProfileIdsRequest",
      fn() -> AuthorizeNet.Customer.get_all end,
      fn(_body, msgs) -> msgs end,
      fn(result) -> assert [35934704] === result end
  end

  test "can get customer profile" do
    request_assert "customer_profile_get", "getCustomerProfileRequest",
      fn() -> AuthorizeNet.Customer.get 35934704 end,
      fn(body, msgs) ->
        assert_fields body, msgs, [{"customerProfileId", "35934704"}]
      end,
      fn(result) ->
        assert %AuthorizeNet.Customer{
          description: "description",
          email: "email2@host.com",
          id: "merchantId",
          profile_id: 35934704
        } === result
      end
  end

  test "cant get inexistant profile" do
    name = start_server fn(_bindings, _headers, _body, req, state) ->
      serve_file "get_inexistant_customer_profile"
    end
    try do
      AuthorizeNet.Customer.get 35934705
      flunk "expected to fail"
    rescue
      e in AuthorizeNet.Error.Operation ->
        {codes, _} = e.message
        assert codes === [{"E00040", "The record cannot be found."}]
    end
    stop_server name
  end

  test "can create customer profile" do
    request_assert "create_customer_profile", "createCustomerProfileRequest",
      fn() ->
        AuthorizeNet.Customer.create "merchantId", "description", "email@host.com"
      end,
      fn(body, msgs) ->
        assert_fields body, msgs, [
          {"merchantCustomerId", "merchantId"},
          {"description", "description"},
          {"email", "email@host.com"}
        ]
      end,
      fn(result) ->
        assert %AuthorizeNet.Customer{
          profile_id: 35934704,
          id: "merchantId",
          description: "description",
          email: "email@host.com"
        } === result
      end
  end

  test "cant create duplicated customer profile" do
    name = start_server fn(_bindings, _headers, _body, req, state) ->
      serve_file "create_duplicated_customer_profile"
    end
    try do
      AuthorizeNet.Customer.create "merchantId", "description", "email@host.com"
      flunk "expected to fail"
    rescue
      e in AuthorizeNet.Error.Operation ->
        {codes, _} = e.message
        assert codes === [{"E00039", "A duplicate record with ID 35938239 already exists."}]
    end
    stop_server name
  end

  test "can update customer profile" do
    request_assert "update_customer_profile", "updateCustomerProfileRequest",
      fn() ->
        AuthorizeNet.Customer.update(
          35934704, "merchantId2", "description2", "email2@host.com"
        )
      end,
      fn(body, msgs) ->
        assert_fields body, msgs, [
          {"description", "description2"},
          {"email", "email2@host.com"},
          {"merchantCustomerId", "merchantId2"},
          {"customerProfileId", "35934704"}
        ]
      end,
      fn(result) ->
        assert %AuthorizeNet.Customer{
          id: "merchantId2",
          description: "description2",
          email: "email2@host.com",
          profile_id: 35934704
        } === result
      end
  end

  test "can delete customer profile" do
    request_assert "delete_customer_profile", "deleteCustomerProfileRequest",
      fn() -> AuthorizeNet.Customer.delete 35934704 end,
      fn(body, msgs) ->
        assert_fields body, msgs, [{"customerProfileId", "35934704"}]
      end,
      fn(result) -> assert result === :ok end
  end

  test "can create invidual credit card payment profile" do
    address = AuthorizeNet.Address.new(
      "first", "last", "company", "street", "city",
      "state", "zip", "country", "phone", "fax"
    )
    card = AuthorizeNet.Card.new "5424000000000015", "2015-08", "900"

    request_assert "create_payment_profile", "createCustomerPaymentProfileRequest",
      fn() ->
        AuthorizeNet.PaymentProfile.create_individual 35938239, address, card
      end,
      fn(body, msgs) ->
        assert_fields body, msgs, [
          {"cardCode", "900"},
          {"expirationDate", "2015-08"},
          {"cardNumber", "5424000000000015"},
          {"faxNumber", "fax"},
          {"phoneNumber", "phone"},
          {"country", "country"},
          {"zip", "zip"},
          {"state", "state"},
          {"city", "city"},
          {"address", "street"},
          {"company", "company"},
          {"lastName", "last"},
          {"firstName", "first"},
          {"customerType", "individual"},
          {"customerProfileId", "35938239"}
        ]
      end,
      fn(result) ->
        assert %AuthorizeNet.PaymentProfile{
          profile_id: 32510145,
          customer_id: 35938239,
          address: address,
          type: :individual,
          payment_type: card
        } === result
      end
  end

  test "can create business credit card payment profile" do
    address = AuthorizeNet.Address.new(
      "first", "last", "company", "street", "city",
      "state", "zip", "country", "phone", "fax"
    )
    card = AuthorizeNet.Card.new "5424000000000015", "2015-08", "900"

    request_assert "create_payment_profile", "createCustomerPaymentProfileRequest",
      fn() ->
        AuthorizeNet.PaymentProfile.create_business 35938239, address, card
      end,
      fn(body, msgs) ->
        assert_fields body, msgs, [
          {"cardCode", "900"},
          {"expirationDate", "2015-08"},
          {"cardNumber", "5424000000000015"},
          {"faxNumber", "fax"},
          {"phoneNumber", "phone"},
          {"country", "country"},
          {"zip", "zip"},
          {"state", "state"},
          {"city", "city"},
          {"address", "street"},
          {"company", "company"},
          {"lastName", "last"},
          {"firstName", "first"},
          {"customerType", "business"},
          {"customerProfileId", "35938239"}
        ]
      end,
      fn(result) ->
        assert %AuthorizeNet.PaymentProfile{
          profile_id: 32510145,
          customer_id: 35938239,
          address: address,
          type: :business,
          payment_type: card
        } === result
      end
  end

  test "cant create account with invalid echeck type" do
    assert_raise ArgumentError, fn() ->
      AuthorizeNet.BankAccount.savings(
        "bank", "111", "222", "name", :whatever
      )
    end
  end

  test "can create savings bank account payment profile" do
    address = AuthorizeNet.Address.new(
      "first", "last", "company", "street", "city",
      "state", "zip", "country", "phone", "fax"
    )
    account = AuthorizeNet.BankAccount.savings(
      "bank", "111", "222", "name", :ccd
    )

    request_assert "create_payment_profile", "createCustomerPaymentProfileRequest",
      fn() ->
        AuthorizeNet.PaymentProfile.create_individual 35938239, address, account
      end,
      fn(body, msgs) ->
        assert_fields body, msgs, [
          {"bankName", "bank"},
          {"echeckType", "CCD"},
          {"nameOnAccount", "name"},
          {"accountNumber", "222"},
          {"routingNumber", "111"},
          {"accountType", "savings"},
          {"country", "country"},
          {"zip", "zip"},
          {"state", "state"},
          {"city", "city"},
          {"address", "street"},
          {"company", "company"},
          {"lastName", "last"},
          {"firstName", "first"},
          {"customerType", "individual"},
          {"customerProfileId", "35938239"}
        ]
      end,
      fn(result) ->
        assert %AuthorizeNet.PaymentProfile{
          profile_id: 32510145,
          customer_id: 35938239,
          address: address,
          type: :individual,
          payment_type: account
        } === result
      end
  end

  test "can create checking bank account payment profile" do
    address = AuthorizeNet.Address.new(
      "first", "last", "company", "street", "city",
      "state", "zip", "country", "phone", "fax"
    )
    account = AuthorizeNet.BankAccount.checking(
      "bank", "111", "222", "name", :web
    )

    request_assert(
      "create_bank_account_payment_profile",
      "createCustomerPaymentProfileRequest",
      fn() ->
        AuthorizeNet.PaymentProfile.create_individual 35938239, address, account
      end,
      fn(body, msgs) ->
        assert_fields body, msgs, [
          {"bankName", "bank"},
          {"echeckType", "WEB"},
          {"nameOnAccount", "name"},
          {"accountNumber", "222"},
          {"routingNumber", "111"},
          {"accountType", "checking"},
          {"country", "country"},
          {"zip", "zip"},
          {"state", "state"},
          {"city", "city"},
          {"address", "street"},
          {"company", "company"},
          {"lastName", "last"},
          {"firstName", "first"},
          {"customerType", "individual"},
          {"customerProfileId", "35938239"}
        ]
      end,
      fn(result) ->
        assert %AuthorizeNet.PaymentProfile{
          profile_id: 32510152,
          customer_id: 35938239,
          address: address,
          type: :individual,
          payment_type: account
        } === result
      end)
  end

  test "can create business checking bank account payment profile" do
    address = AuthorizeNet.Address.new(
      "first", "last", "company", "street", "city",
      "state", "zip", "country", "phone", "fax"
    )
    account = AuthorizeNet.BankAccount.business_checking(
      "bank", "111", "222", "name", :ppd
    )

    request_assert "create_payment_profile", "createCustomerPaymentProfileRequest",
      fn() ->
        AuthorizeNet.PaymentProfile.create_individual 35938239, address, account
      end,
      fn(body, msgs) ->
        assert_fields body, msgs, [
          {"bankName", "bank"},
          {"echeckType", "PPD"},
          {"nameOnAccount", "name"},
          {"accountNumber", "222"},
          {"routingNumber", "111"},
          {"accountType", "businessChecking"},
          {"country", "country"},
          {"zip", "zip"},
          {"state", "state"},
          {"city", "city"},
          {"address", "street"},
          {"company", "company"},
          {"lastName", "last"},
          {"firstName", "first"},
          {"customerType", "individual"},
          {"customerProfileId", "35938239"}
        ]
      end,
      fn(result) ->
        assert %AuthorizeNet.PaymentProfile{
          profile_id: 32510145,
          customer_id: 35938239,
          address: address,
          type: :individual,
          payment_type: account
        } === result
      end
  end

  test "can get payment profile" do
    address = AuthorizeNet.Address.new(
      "first", "last", "company", "street", "city",
      "state", "zip", "country", "phone", "fax"
    )
    card = AuthorizeNet.Card.new "XXXX0015", "XXXX", nil

    request_assert "get_payment_profile", "getCustomerPaymentProfileRequest",
      fn() -> AuthorizeNet.PaymentProfile.get 35947873, 32510145 end,
      fn(body, msgs) ->
        assert_fields body, msgs, [
          {"customerProfileId", "35947873"},
          {"customerPaymentProfileId", "32510145"}
        ]
      end,
      fn(result) ->
        assert %AuthorizeNet.PaymentProfile{
          profile_id: 32510145,
          customer_id: 35947873,
          address: address,
          type: :individual,
          payment_type: card
        } === result
      end
  end

  test "can validate payment profile" do
    request_assert "valid_payment_profile", "validateCustomerPaymentProfileRequest",
      fn() -> AuthorizeNet.PaymentProfile.valid? 35947873, 32500939, 900 end,
      fn(body, msgs) ->
        assert_fields body, msgs, [
          {"customerProfileId", "35947873"},
          {"customerPaymentProfileId", "32500939"},
          {"cardCode", "900"},
          {"validationMode", "none"}
        ]
      end,
      fn(result) -> assert result end

    request_assert "invalid_payment_profile", "validateCustomerPaymentProfileRequest",
      fn() -> AuthorizeNet.PaymentProfile.valid? 35947873, 32500939, 900 end,
      fn(body, msgs) ->
        assert_fields body, msgs, [
          {"customerProfileId", "35947873"},
          {"customerPaymentProfileId", "32500939"},
          {"cardCode", "900"},
          {"validationMode", "none"}
        ]
      end,
      fn(result) ->
        {false, op} = result
        {codes, _} = op.message
        assert codes === [{"E00027", "Card Code is required."}]
      end
  end

  test "can delete payment profile" do
    request_assert "delete_payment_profile", "deleteCustomerPaymentProfileRequest",
      fn() -> AuthorizeNet.PaymentProfile.delete 35947873, 32500939 end,
      fn(body, msgs) ->
        assert_fields body, msgs, [
          {"customerProfileId", "35947873"},
          {"customerPaymentProfileId", "32500939"}
        ]
      end,
      fn(result) -> assert result === :ok end
  end

  test "can create shipping address" do
    address = AuthorizeNet.Address.new(
      "first", "last", "company", "street", "city",
      "state", "zip", "country", "phone", "fax"
    )
    request_assert "create_shipping_address", "createCustomerShippingAddressRequest",
      fn() -> AuthorizeNet.Customer.create_shipping_address 35947873, address end,
      fn(body, msgs) ->
        assert_fields body, msgs, [
          {"customerProfileId", "35947873"},
          {"country", "country"},
          {"zip", "zip"},
          {"state", "state"},
          {"city", "city"},
          {"phoneNumber", "phone"},
          {"faxNumber", "fax"}
        ]
      end,
      fn(result) ->
        assert %AuthorizeNet.Address{
          customer_id: 35947873,
          id: 34066037,
          first_name: "first",
          last_name: "last",
          company: "company",
          country: "country",
          zip: "zip",
          phone: "phone",
          fax: "fax",
          address: "street",
          city: "city",
          state: "state"
        } === result
      end
  end

  test "can get shipping address" do
    request_assert "get_shipping_address", "getCustomerShippingAddressRequest",
      fn() -> AuthorizeNet.Customer.get_shipping_address 35947873, 34066037 end,
      fn(body, msgs) ->
        assert_fields body, msgs, [
          {"customerProfileId", "35947873"},
          {"customerAddressId", "34066037"},
        ]
      end,
      fn(result) ->
        assert %AuthorizeNet.Address{
          customer_id: 35947873,
          id: 34066037,
          first_name: "first",
          last_name: "last",
          company: "company",
          country: "country",
          zip: "zip",
          phone: "phone",
          fax: "fax",
          address: "street",
          city: "city",
          state: "state"
        } === result
      end
  end

  test "can update shipping address" do
    address = AuthorizeNet.Address.new(
      "first", "last", "company", "street", "city",
      "state", "zip", "country", "phone", "fax"
    )
    address = %AuthorizeNet.Address{address | id: 1, customer_id: 2}
    request_assert "update_shipping_address", "updateCustomerShippingAddressRequest",
      fn() -> AuthorizeNet.Customer.update_shipping_address address end,
      fn(body, msgs) ->
        assert_fields body, msgs, [
          {"customerProfileId", "2"},
          {"country", "country"},
          {"zip", "zip"},
          {"state", "state"},
          {"city", "city"},
          {"phoneNumber", "phone"},
          {"faxNumber", "fax"}
        ]
      end,
      fn(result) ->
        assert %AuthorizeNet.Address{
          customer_id: 2,
          id: 1,
          first_name: "first",
          last_name: "last",
          company: "company",
          country: "country",
          zip: "zip",
          phone: "phone",
          fax: "fax",
          address: "street",
          city: "city",
          state: "state"
        } === result
      end
  end

  test "can delete shipping address" do
    request_assert "delete_shipping_address", "deleteCustomerShippingAddressRequest",
      fn() -> AuthorizeNet.Customer.delete_shipping_address 35962612, 34066037  end,
      fn(body, msgs) ->
        assert_fields body, msgs, [
          {"customerProfileId", "35962612"},
          {"customerAddressId", "34066037"}
        ]
      end,
      fn(result) -> assert :ok === result end
  end

  test "can do a generic auth_only transaction" do
    request_assert "transaction", "createTransactionRequest",
      fn() ->
        alias AuthorizeNet.Transaction, as: T
        T.new |>
        T.auth_only() |>
        T.run
      end,
      fn(body, msgs) ->
        assert_fields(body, msgs, [
          {"transactionType", "authOnlyTransaction"}
        ])
      end,
      fn(_result) -> true end
  end

  test "can do a generic void transaction" do
    request_assert "transaction", "createTransactionRequest",
      fn() ->
        alias AuthorizeNet.Transaction, as: T
        T.new |>
        T.void("1234") |>
        T.run
      end,
      fn(body, msgs) ->
        assert_fields(body, msgs, [
          {"transactionType", "voidTransaction"}
        ])
      end,
      fn(_result) -> true end
  end

  test "can do a generic prior auth capture transaction" do
    request_assert "transaction", "createTransactionRequest",
      fn() ->
        alias AuthorizeNet.Transaction, as: T
        T.new |>
        T.prior_auth_capture |>
        T.run
      end,
      fn(body, msgs) ->
        assert_fields(body, msgs, [
          {"transactionType", "priorAuthCaptureTransaction"}
        ])
      end,
      fn(_result) -> true end
  end

  test "can do a generic capture only transaction" do
    request_assert "transaction", "createTransactionRequest",
      fn() ->
        alias AuthorizeNet.Transaction, as: T
        T.new |>
        T.capture_only |>
        T.run
      end,
      fn(body, msgs) ->
        assert_fields(body, msgs, [
          {"transactionType", "captureOnlyTransaction"}
        ])
      end,
      fn(_result) -> true end
  end

  test "can do a generic refund transaction" do
    request_assert "transaction", "createTransactionRequest",
      fn() ->
        alias AuthorizeNet.Transaction, as: T
        T.new |>
        T.refund("123123") |>
        T.run
      end,
      fn(body, msgs) ->
        assert_fields(body, msgs, [
          {"transactionType", "refundTransaction"}
        ])
      end,
      fn(_result) -> true end
  end

  test "can do a generic failed transaction" do
    request_assert "failed_transaction", "createTransactionRequest",
      fn() ->
        alias AuthorizeNet.Transaction, as: T
        T.new |>
        T.auth_capture() |>
        T.run
      end,
      fn(_body, _msgs) -> [] end,
      fn(result) -> refute result.success end
  end

  test "can do a generic transaction" do
    request_assert "transaction", "createTransactionRequest",
      fn() ->
        card = AuthorizeNet.Card.new "5424000000000015", "2015-08", "901"
        address = AuthorizeNet.Address.new(
          "first_name",
          "last_name",
          "company",
          "street",
          "city",
          "state",
          "46282",
          "country",
          "phone",
          "fax"
        )
        alias AuthorizeNet.Transaction, as: T
        T.new(3.01) |>
        T.ref_transaction_id("9992") |>
        T.customer_individual("id1", "email@host.com") |>
        T.enable_partial_auth |>
        T.enable_duplicate_window |>
        T.enable_test_request |>
        T.auth_capture() |>
        T.employee_id(5678) |>
        T.market_retail |>
        T.device_virtual_terminal |>
        T.tax_exempt |>
        T.auth_code("44556") |>
        T.tax("tax_name", "tax_description", 3.44) |>
        T.duty("duty_name", "duty_description", 3.44) |>
        T.ship_to(address) |>
        T.shipping_cost("ship_cost", "ship_description", 3.44) |>
        T.user_fields(%{"key1": "value1", "key2": "value2"}) |>
        T.order("4455", "order_description") |>
        T.add_item(1, "item1", "itemdesc1", 1, 1.00) |>
        T.add_item(2, "item2", "itemdesc2", 1, 2.00) |>
        T.po_number("po_number") |>
        T.bill_to(address) |>
        T.pay_with_card(card) |>
        T.pay_with_customer_profile(35962612, 32510145, 34066235, "901") |>
        T.customer_ip("127.0.0.1") |>
        T.run
      end,
      fn(body, msgs) ->
        [profile] = xml_find body, "//profile"
        [order] = xml_find body, "//order"
        [f1, f2] = xml_find body, "//userField"
        [ship_to] = xml_find body, "//shipTo"
        [bill_to] = xml_find body, "//billTo"
        [i1, i2] = xml_find body, "//lineItem"
        [tax] = xml_find body, "//tax"
        [duty] = xml_find body, "//duty"
        [shipping] = xml_find body, "//shipping"
        [s1, s2, s3] = xml_find body, "//setting"
        [customer] = xml_find body, "//customer"
        assert "3.01" === hd(xml_value body, "//amount")
        msgs = assert_fields(body, msgs, [
          {"marketType", "2"},
          {"deviceType", "10"},
          {"refTransId", "9992"},
          {"customerIP", "127.0.0.1"},
          {"employeeId", "5678"},
          {"taxExempt", "true"},
          {"poNumber", "po_number"},
          {"authCode", "44556"},
          {"transactionType", "authCaptureTransaction"}
        ])
        assert_fields(profile, msgs, [
          {"customerProfileId", "35962612"},
          {"paymentProfileId", "32510145"},
          {"shippingProfileId", "34066235"},
          {"cardCode", "901"}
        ])
        assert_fields(order, msgs, [
          {"invoiceNumber", "4455"},
          {"description", "order_description"}
        ])
        assert_fields(i1, msgs, [
          {"itemId", "1"},
          {"name", "item1"},
          {"description", "itemdesc1"},
          {"quantity", "1"},
          {"unitPrice", "1.0"}
        ])
        assert_fields(i2, msgs, [
          {"itemId", "2"},
          {"name", "item2"},
          {"description", "itemdesc2"},
          {"quantity", "1"},
          {"unitPrice", "2.0"}
        ])
        assert_fields(ship_to, msgs, [
          {"firstName", "first_name"},
          {"lastName", "last_name"},
          {"company", "company"},
          {"address", "street"},
          {"city", "city"},
          {"state", "state"},
          {"zip", "46282"},
          {"country", "country"}
        ])
        assert_fields(f2, msgs, [
          {"name", "key2"},
          {"value", "value2"}
        ])
        assert_fields(f1, msgs, [
          {"name", "key1"},
          {"value", "value1"}
        ])
        assert_fields(bill_to, msgs, [
          {"firstName", "first_name"},
          {"lastName", "last_name"},
          {"company", "company"},
          {"address", "street"},
          {"city", "city"},
          {"state", "state"},
          {"zip", "46282"},
          {"country", "country"},
          {"faxNumber", "fax"},
          {"phoneNumber", "phone"}
        ])
        assert_fields(tax, msgs, [
          {"name", "tax_name"},
          {"description", "tax_description"},
          {"amount", "3.44"}
        ])
        assert_fields(duty, msgs, [
          {"name", "duty_name"},
          {"description", "duty_description"},
          {"amount", "3.44"}
        ])
        assert_fields(shipping, msgs, [
          {"name", "ship_cost"},
          {"description", "ship_description"},
          {"amount", "3.44"}
        ])
        assert_fields(s1, msgs, [
          {"settingName", "allowPartialAuth"},
          {"settingValue", "true"}
        ])
        assert_fields(s2, msgs, [
          {"settingName", "duplicateWindow"},
          {"settingValue", "true"}
        ])
        assert_fields(s3, msgs, [
          {"settingName", "testRequest"},
          {"settingValue", "true"}
        ])
        assert_fields(customer, msgs, [
          {"type", "individual"},
          {"id", "id1"},
          {"email", "email@host.com"}
        ])
      end,
      fn(result) ->
        assert result === %AuthorizeNet.TransactionResponse{
          code: 1,
          auth_code: "000000",
          avs_result: "P",
          cvv_result: "A",
          cavv_result: "Z",
          transaction_id: "0",
          ref_transaction_id: "AAAA",
          transaction_hash: "ABE0074FA756F889478472425EA85DBE",
          test_request: "1",
          account_number: "XXXX0015",
          account_type: "MasterCard",
          errors: [{"I00001", "Successful."}],
          user_fields: [{"a", "B"}, {"b", "f"}],
          success: true,
          operation_errors: [{"54", "The referenced transaction does not meet the criteria for issuing a credit."}]
        }
      end
  end

  defp request_assert(
    file, request_type, request_fun, server_asserts_fun, client_asserts_fun
  ) do
    me = self
    server_name = start_server fn(_bindings, _headers, body, req, state) ->
      msgs = []
      msgs = case validate body do
        {:error, error} -> ["invalid schema: #{inspect error}"|msgs]
        :ok -> msgs
      end
      msgs = if xml_find(body, "//#{request_type}") === [] do
        ["missing request section"|msgs]
      else
        msgs
      end
      msgs = server_asserts_fun.(body, msgs)
      send me, msgs
      serve_file file
    end
    result = request_fun.()
    stop_server server_name
    receive do
      [] -> client_asserts_fun.(result)
      x -> flunk "Something went wrong with the request: #{inspect x}"
    end
  end
end
