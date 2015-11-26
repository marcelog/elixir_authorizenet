[![Build Status](https://travis-ci.org/marcelog/elixir_authorizenet.svg)](https://travis-ci.org/marcelog/elixir_authorizenet)

# elixir_authorizenet

Elixir client for the [Authorize.Net merchant API](http://developer.authorize.net/api/reference/index.html). This
should help you integrate using the [AIM](http://developer.authorize.net/api/aim/).

A nice number of features are implemented (probably most of the ones used
on a daily basis are already there), but since the API offers a big number of
features and combinations, I still consider this as WIP, and pull requests,
suggestions, or other kind of feedback are very welcome!

# Using it with Mix

To use it in your Mix projects, first add it as a dependency:

```elixir
def deps do
  [{:elixir_authorizenet, "~> 0.2.0"}]
end
```
Then run mix deps.get to install it.

----

# Configuring
In your config.exs, setup the following section:

```elixir
config :elixir_authorizenet,
  environment: :sandbox,  # :sandbox or :production
  validation_mode: :test, # :test, :live, or :none
  login_id: "login_id",
  transaction_key: "transaction_key"
```

----

# Documentation

What follows is just a glance, a quick overview of the common used features.
Feel free to take a look at the [documentation](http://hexdocs.pm/elixir_authorizenet/)
served by hex.pm or the source itself to find more.

## Customer Profiles
These are used when you want to store information in the Authorize.Net servers,
like credit card or bank account information, and also billing and shipping
addresses. This effectively is the interface to the [CIM](http://developer.authorize.net/api/cim/).

Customer Profiles are used via the [Customer](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/customer.ex) module.

```elixir
alias AuthorizeNet.Customer, as: C
```

### Creating
```elixir
  > C.create "merchantId", "description", "email@host.com"
  %AuthorizeNet.Customer{description: "description", email: "email@host.com",
   id: "merchantId", payment_profiles: [], profile_id: 35962612,
   shipping_addresses: []}
```

### Updating
```elixir
  > C.update 35962612, "merchantId", "description", "email2@host.com"
  %AuthorizeNet.Customer{description: "description", email: "email2@host.com",
   id: "merchantId", payment_profiles: [], profile_id: 35962612,
   shipping_addresses: []}
```

### Get all IDs
```elixir
  > C.get_all
  [35962612]
```

### Get Customer Profile
```elixir
  > C.get 35962612
  %AuthorizeNet.Customer{description: "description", email: "email2@host.com",
   id: "merchantId", payment_profiles: [], profile_id: 35962612,
   shipping_addresses: []}
```

### Deleting
```elixir
  > C.delete 35962612
  :ok
```

----

## Addresses
To handle billing and shipping addresses, use the [Address](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/address.ex)
module.
```elixir
alias AuthorizeNet.Address, as: A

address = A.new(
  "first_name",
  "last_name",
  "company",
  "street",
  "city",
  "state",
  "zip",
  "country",
  "phone",
  "fax"
)
%AuthorizeNet.Address{address: "street", city: "city", company: "company",
 country: "country", customer_id: nil, fax: "fax", first_name: "first_name",
 id: nil, last_name: "last_name", phone: "phone", state: "state", zip: "zip"}
```

----
## Shipping Addresses
You can do some CRUD with shipping addresses in a customer profile.

### Creating
```elixir
  > C.create_shipping_address 35962612, address
  %AuthorizeNet.Address{address: "street", city: "city", company: "company",
   country: "country", customer_id: 35962612, fax: "fax",
   first_name: "first_name", id: 34066037, last_name: "last_name", phone: "phone",
   state: "state", zip: "zip"}
```

### Getting
```elixir
  > C.get_shipping_address 35962612, 34066037
  %AuthorizeNet.Address{address: "street", city: "city", company: "company",
   country: "country", customer_id: 35962612, fax: "fax",
   first_name: "first_name", id: 34066037, last_name: "last_name", phone: "phone",
   state: "state", zip: "zip"}
```

### Updating
Make sure you have an `AuthorizeNet.Address` struct with customer_id and id already filled in
(for example by getting it from the server). Then:

```elixir
  > C.update_shipping_address address
  %AuthorizeNet.Address{address: "street", city: "city", company: "company",
   country: "country", customer_id: 35962612, fax: "fax",
   first_name: "first_name", id: 34066235, last_name: "last_name", phone: "phone",
   state: "state", zip: "zip2"}
```

### Deleting
```elixir
  > C.delete_shipping_address 35962612, 34066037
  :ok
```
----

## Customer Payment Profiles

Payment profiles are handled in the [PaymentProfile](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/payment_profile.ex)
module. With a PaymentProfile you can declare credit cards and bank accounts and
save them into a customer profile. Bank accounts are handled by the module [BankAccount](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/bank_account.ex)
while credit cards are handled by the module [Card](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/card.ex).

```elixir
alias AuthorizeNet.PaymentProfile, as: P
alias AuthorizeNet.BankAccount, as: BankAccount
alias AuthorizeNet.Card, as: Card
```

And can be created with the functions:

 * **AuthorizeNet.PaymentProfile.create_business**: To create a "business" associated payment profile.
 * **AuthorizeNet.PaymentProfile.create_individual**: To create a payment profile for an individual, not associated to a business.

### Creating a Credit Card
```elixir
  > card = Card.new "5424000000000015", "2015-08", "900"
  %AuthorizeNet.Card{code: "900", expiration_date: "2015-08",
   number: "5424000000000015"}

  > P.create_individual 35962612, address, card
  %AuthorizeNet.PaymentProfile{address: %AuthorizeNet.Address{address: "street",
    city: "city", company: "company", country: "country", customer_id: nil,
    fax: "fax", first_name: "first_name", id: nil, last_name: "last_name",
    phone: "phone", state: "state", zip: "zip"}, customer_id: 35962612,
   payment_type: %AuthorizeNet.Card{code: "900", expiration_date: "2015-08",
    number: "5424000000000015"}, profile_id: 32510145, type: :individual}
```

### Creating a bank account
Bank accounts can be created via 3 functions:

 * **AuthorizeNet.BankAccount.savings**: A savings account.
 * **AuthorizeNet.BankAccount.checking**: A checking account.
 * **AuthorizeNet.BankAccount.business_checking**: A business checking account.

```elixir
  > account = BankAccount.savings "bank_name", "routing_number", "account_number", "name_on_account", :ccd
  %AuthorizeNet.BankAccount{account_number: "account_number",
   bank_name: "bank_name", echeck_type: :ccd, name_on_account: "name_on_account",
   routing_number: "routing_number", type: :savings}

  > P.create_individual 35962612, address, account
  %AuthorizeNet.PaymentProfile{address: %AuthorizeNet.Address{address: "street",
    city: "city", company: "company", country: "country", customer_id: nil,
    fax: "fax", first_name: "first_name", id: nil, last_name: "last_name",
    phone: "phone", state: "state", zip: "zip"}, customer_id: 35962612,
   payment_type: %AuthorizeNet.BankAccount{account_number: "account_number",
    bank_name: "bank_name", echeck_type: :web, name_on_account: "name_on_account",
    routing_number: "routing_number", type: :savings}, profile_id: 32510152,
   type: :individual}
```

The last argument is the type of [echeck](https://www.authorize.net/support/CNP/helpfiles/Miscellaneous/Pop-up_Terms/ALL/eCheck.Net_Type.htm).

### Getting a payment profile
```elixir
  > P.get 35962612, 32510152
  %AuthorizeNet.PaymentProfile{address: %AuthorizeNet.Address{address: "street",
    city: "city", company: "company", country: "country", customer_id: nil,
    fax: "fax", first_name: "first_name", id: nil, last_name: "last_name",
    phone: "phone", state: "state", zip: "zip"}, customer_id: 35962612,
   payment_type: %AuthorizeNet.BankAccount{account_number: "XXXX0999",
    bank_name: "bank_name", echeck_type: :web, name_on_account: "name_on_account",
    routing_number: "XXXX3093", type: :savings}, profile_id: 32510152,
   type: :individual}
```

There is a third argument available which is a list of options. The available
options are:

 * **:unmask_expiration_date**: For payment profiles associated to credit cards,
 this will return the expiration date unmasked.

Example:
```elixir
  > P.get 35962612, 34818508, [:unmask_expiration_date]
```

### Searching for payment profiles
This will return all the payment profiles of all customers that matches the
given criteria. For more information about the values allowed see:
[http://developer.authorize.net/api/reference/#customer-profiles-get-customer-payment-profile-list](http://developer.authorize.net/api/reference/#customer-profiles-get-customer-payment-profile-list).

```elixir
  > P.get_list "cardsExpiringInMonth", "2016-08", "id", false, 100, 1
  [%AuthorizeNet.PaymentProfile{address: %AuthorizeNet.Address{address: "street",
   city: "city", company: "company", country: "country", customer_id: 38311592,
   fax: "fax", first_name: "first_name", id: nil, last_name: "last_name",
   phone: "phone", state: "state", zip: "zip"}, customer_id: 38311592,
   payment_type: %AuthorizeNet.Card{code: nil, expiration_date: "XXXX",
   number: "XXXX0015"}, profile_id: 34818508, type: nil}]
```

### Validating
```elixir
  > P.valid? 35962612, 32510145
  {false,
   %AuthorizeNet.Error.Operation{message: [{"E00027", "Card Code is required."}]}}

  > P.valid? 35962612, 32510145, "900"
  true
```

### Deleting
```elixir
  > AuthorizeNet.PaymentProfile.delete 35962612, 32510145
  :ok
```

----

## Making transactions

### In a nutshell
Transactions are made via the [Transaction](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/transaction.ex) module.
To create a transaction, just call the `new` function, passing an optional amount (a float) as the argument.

```elixir
alias AuthorizeNet.Transaction, as: T

T.new(12.34)
```

To run a transaction, just call the `run` function:
```elixir
T.new(12.34) |>
T.run
```

### TransactionResponse
All transactions will return a [TransactionResponse](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/transaction_response.ex)
struct, like:

```elixir
%AuthorizeNet.TransactionResponse{account_number: "XXXX0015",
 account_type: "MasterCard", auth_code: "QWIDX2", avs_result: "Y",
 cavv_result: nil, code: 1, cvv_result: nil,
 errors: [{"I00001", "Successful."}], operation_errors: [],
 ref_transaction_id: nil, success: true, test_request: "0",
 transaction_hash: "D05A1D1C4558FB329522CCFC62B4A7F3",
 transaction_id: "2235759738", user_fields: [{"key1", "value1"}, {"key2", "value2"}]}
```

### Transaction types
Authorize.Net supports different [transaction types](https://support.authorize.net/authkb/index?page=content&id=A510).
You can choose between them as follows:
```elixir
T.new                     |>
T.auth_capture()          # or
T.auth_only()             # or
T.capture_only()          # or
T.prior_auth_capture()    # or
T.void(transaction_id)    # or
T.refund(transaction_id)  # or
```

### Adding customer, billing and shipping information
These might or might not be required depending on the type of payment you choose
(i.e: customer profiles include the billing and shipping information in their
payment profile ids and shipping address ids respectively):

```elixir
T.bill_to(address)                             |>
T.ship_to(address)                             |>
T.customer_individual("id1", "email@host.com") |>

# You can also specify a "business" customer instead:
T.customer_business("id1", "email@host.com")
```

### Transaction Settings
You can enable and disable different transaction settings, like:
```elixir
T.enable_partial_auth      |>  # or T.disable_partial_auth
T.enable_duplicate_window  |>  # or T.disable_duplicate_window
T.enable_test_request      |>  # or T.disable_test_request
T.enable_recurring_billing |>  # or T.disable_recurring_billing
T.enable_email_customer        # or T.disable_email_customer
```

### Adding tax information
Optionally, you can add some tax information:
```elixir
T.not_tax_exempt                              |> # or T.tax_exempt
T.tax("name", "description", 3.44)            |>
T.duty("name", "description", 3.44)           |>
T.shipping_cost("name", "description", 3.44)
```

### Adding order information
You can include the order information (and optionally any billing items and
purchase order ) like this:

```elixir
T.order("4455", "order description")         |>
T.add_item(1, "item1", "itemdesc1", 1, 1.00) |>
T.add_item(2, "item2", "itemdesc2", 1, 2.00) |>
T.po_number("po_number_1")
```

### Specifying market type
```elixir
T.market_retail    # or
T.market_ecommerce # or
T.market_moto
```

### Specifying device type
```elixir
T.device_website                  # or
T.device_unknown                  # or
T.device_unattended_terminal      # or
T.device_electronic_cash_register # or
T.device_personal_computer        # or
T.device_air_pay                  # or
T.device_self_service_terminal    # or
T.device_wireless_pos             # or
T.device_dial_terminal            # or
T.device_virtual_terminal         # or
```

### Adding custom fields
```elixir
T.user_fields(%{
  "key1": "value1",
  "key2": "value2"
})
```

### Other information you can add to the transaction.
```elixir
T.auth_code("QFBYYN")              |> # Used for already authorised transactions.
T.ref_transaction_id("2235786422") |> # Used to refund or credit
T.employee_id(5678)                |>
T.customer_ip("127.0.0.1")
```

### Paying with credit card
```elixir
T.new(10.25)                         |>
T.auth_capture()                     |>
T.bill_to(address)                   |>
T.pay_with_card(card)                |>
T.order("4455", "order description") |>
T.run
```

### Paying with a payment profile id
```elixir
T.new(10.25)                         |>
T.auth_capture()                     |>
T.pay_with_customer_profile(
  customer_profile_id,
  payment_profile_id,
  shipping_address_id,
  card_code
)                                    |>
T.order("4455", "order description") |>
T.run
```

### Paying with Apple Pay
```elixir
T.new(10.25)                         |>
T.auth_capture()                     |>
T.pay_with_apple_pay(encrypted_data) |>
T.order("4455", "order description") |>
T.run
```

### Paying with a Bank Account
```elixir
T.new(10.25)                         |>
T.bill_to(address)                   |>
T.auth_capture()                     |>
T.pay_with_bank_account(account)     |>
T.order("4455", "order description") |>
T.run
```

### Voiding a transaction
```elixir
T.new                |>
T.void("2235759535") |>
T.run
```

### Refund a transaction
```elixir
T.new(3.00)                          |>
T.bill_to(address)                   |>
T.order("4455", "order description") |>
T.pay_with_card(card)                |>
T.refund("2235759535")               |>
T.run
```

----

## Errors

These errors might be raised by the API calls:

 * [AuthorizeNet.Error.Connection](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/error/connection_error.ex): There was an error when trying to hit the API endpoint (like a network issue).

 * [AuthorizeNet.Error.Request](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/error/request_error.ex): The request was sent and received by the server, but it returned a status different than 200.

 * [AuthorizeNet.Error.Operation](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/error/operation_error.ex): The request was sent and received successfully, a status 200 was returned by the server, but there was an error when trying to process the operation.

# License
The source code is released under Apache 2 License.

Check [LICENSE](https://github.com/marcelog/elixir_authorizenet/blob/master/LICENSE) file for more information.

# TODO
 * Allow payment profiles when creating a customer profile.
 * Add support for [hosted profile page](http://developer.authorize.net/api/reference/index.html#manage-customer-profiles-get-hosted-profile-page).
 * Add support for [creating a customer profile from a successful transaction](http://developer.authorize.net/api/reference/index.html#manage-customer-profiles-create-a-customer-profile-from-a-transaction).
 * Add support for [recurring billing](http://developer.authorize.net/api/reference/index.html#recurring-billing).

# Useful Authorize.Net documentation
 * [API reference](http://developer.authorize.net/api/reference/).
 * [Transaction Types](https://support.authorize.net/authkb/index?page=content&id=A510).
 * How to generate [specific error codes](http://developer.authorize.net/tools/errorgenerationguide/) useful for testing purposes.
 * Error reason [check tool](http://developer.authorize.net/tools/responsereasoncode/).
 * [FAQ about sandbox environment](https://community.developer.authorize.net/t5/The-Authorize-Net-Developer-Blog/Authorize-Net-Sandbox-FAQs/ba-p/17440).
