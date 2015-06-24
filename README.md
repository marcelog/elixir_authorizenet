[![Build Status](https://travis-ci.org/marcelog/elixir_authorizenet.svg)](https://travis-ci.org/marcelog/elixir_authorizenet)

elixir_authorizenet
===================

Elixir client for the [Authorize.Net merchant API](http://developer.authorize.net/api/reference/index.html).
This is WIP.

Take a look at the [documentation](http://hexdocs.pm/elixir_authorizenet/) served by hex.pm.

## Using it with Mix

To use it in your Mix projects, first add it as a dependency:

```elixir
def deps do
  [{:elixir_authorizenet, "~> 0.0.1"}]
end
```
Then run mix deps.get to install it.

----

## Customer Profiles

### Creating
```elixir
  > AuthorizeNet.Customer.create "merchantId", "description", "email@host.com"
  %AuthorizeNet.Customer{profile_id: 35934704, id: "merchantId",
   description: "description", email: "email@host.com", payment_profiles: []}
```

### Updating
```elixir
  > AuthorizeNet.Customer.update 35934704, "merchantId", "description", "email2@host.com"
  %AuthorizeNet.Customer{id: "merchantId", description: "description",
   email: "email2@host.com", profile_id: 35934704, payment_profiles: []}
```

### Get all IDs
```elixir
  > AuthorizeNet.Customer.get_all
  [35934704]
```

### Get Customer Profile
```elixir
  > AuthorizeNet.Customer.get 35934704
  %AuthorizeNet.Customer{description: "description", email: "email2@host.com",
   id: "merchantId", profile_id: 35934704, payment_profiles: []}
```

### Deleting
```elixir
  > AuthorizeNet.Customer.delete 35934704
  :ok
```

----
## Shipping Addresses

### Creating
```elixir
  > AuthorizeNet.Customer.create_shipping_address 35947873, address
  %AuthorizeNet.Address{address: "street", city: "city", country: "country",
   customer_id: 35947873, fax: "fax", id: 34065443, phone: "phone",
   state: "state", zip: "zip"}
```

### Getting
```elixir
  > AuthorizeNet.Customer.get_shipping_address 35947873, 34065443
  %AuthorizeNet.Address{address: "street", city: "city", country: "country",
   customer_id: 35947873, fax: "fax", id: 34065443, phone: "phone",
   state: "state", zip: "zip"}
```
----

## Customer Payment Profiles

Payment profiles can be created with the functions:

 * **AuthorizeNet.PaymentProfile.create_business**: To create a "business" associated payment profile.
 * **AuthorizeNet.PaymentProfile.create_individual**: To create a payment profile for an individual, not associated to a business.

To create a Payment Profile, you first need to create a billing address:

```elixir
  > address = AuthorizeNet.Address.new "street", "city", "state", "zip", "country", "phone", "fax"
  %AuthorizeNet.Address{address: "street", city: "city", country: "country",
   fax: "fax", phone: "phone", state: "state", zip: "zip"}
```

Then:

### Creating a Credit Card
```elixir
  > card = AuthorizeNet.Card.new "5424000000000015", "2015-08", "900"
  %AuthorizeNet.Card{code: "900", expiration_date: "2015-08",
   number: "5424000000000015"}

  > AuthorizeNet.PaymentProfile.create_individual 35947873, "first_name", "last_name", "company", address, card
  %AuthorizeNet.PaymentProfile{address: %AuthorizeNet.Address{address: "street",
    city: "city", country: "country", fax: "fax", phone: "phone", state: "state",
    zip: "zip"}, company: "company", customer_id: 35947873,
   first_name: "first_name", last_name: "last_name",
   payment_type: %AuthorizeNet.Card{code: "900", expiration_date: "2015-08",
    number: "5424000000000015"}, profile_id: 32500939, type: :individual}
```

### Creating a bank account
Bank accounts can be created via 3 functions:

 * **AuthorizeNet.BankAccount.savings**: A savings account.
 * **AuthorizeNet.BankAccount.checking**: A checking account.
 * **AuthorizeNet.BankAccount.business_checking**: A business checking account.

```elixir
  > account = AuthorizeNet.BankAccount.savings "bank_name", "routing_number", "account_number", "name_on_account", :ccd
  %AuthorizeNet.BankAccount{account_number: "account_number",
   bank_name: "bank_name", echeck_type: :ccd, name_on_account: "name_on_account",
   routing_number: "routing_number", type: :savings}

  > AuthorizeNet.PaymentProfile.create_individual 35947873, "first_name", "last_name", "company", address, account
```

The last argument is the type of [echeck](https://www.authorize.net/support/CNP/helpfiles/Miscellaneous/Pop-up_Terms/ALL/eCheck.Net_Type.htm).

### Getting a payment profile
```elixir
  > AuthorizeNet.PaymentProfile.get 35947873, 32500939
%AuthorizeNet.PaymentProfile{address: %AuthorizeNet.Address{address: "street",
  city: "city", country: "country", fax: "fax", phone: "phone", state: "state",
  zip: "zip"}, company: "company", customer_id: 35947873,
 first_name: "first_name", last_name: "last_name",
 payment_type: %AuthorizeNet.Card{code: nil, expiration_date: "XXXX",
  number: "XXXX0015"}, profile_id: 32500939, type: :individual}
```

### Validating
```elixir
  > AuthorizeNet.PaymentProfile.valid? 35947873, 32500939
  {false,
   %AuthorizeNet.Error.Operation{message: [{"E00027", "Card Code is required."}]}}

  > AuthorizeNet.PaymentProfile.valid? 35947873, 32500939, "900"
  true
```

### Deleting
```elixir
  > AuthorizeNet.PaymentProfile.delete 35947873, 32500879
  :ok
```

----

## Errors

These errors might be raised by the API calls:

 * [AuthorizeNet.Error.Connection](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/error/connection_error.ex): There was an error when trying to hit the API endpoint (like a network issue).

 * [AuthorizeNet.Error.Request](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/error/request_error.ex): The request was sent and received by the server, but it returned a status different than 200.

 * [AuthorizeNet.Error.Operation](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/error/operation_error.ex): The request was sent and received successfully, a status 200 was returned by the server, but there was an error when trying to process the operation.

## License
The source code is released under Apache 2 License.

## TODO
 * Add support for updating a payment profile.
 * Allow payment profiles when creating a customer profile.

Check [LICENSE](https://github.com/marcelog/elixir_authorizenet/blob/master/LICENSE) file for more information.
