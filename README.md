AuthorizeNet
============

Elixir client for the [Authorize.Net merchant API](http://developer.authorize.net/api/reference/index.html).
This is WIP.

## Customer Profiles

### Creating
```elixir
  > AuthorizeNet.Customer.create "merchantId", "description", "email@host.com"
  %AuthorizeNet.Customer{profile_id: 35934704, id: "merchantId",
   description: "description", email: "email@host.com"}
```

### Updating
```elixir
  > AuthorizeNet.Customer.update 35934704, "merchantId", "description", "email2@host.com"
  %AuthorizeNet.Customer{id: "merchantId", description: "description",
   email: "email2@host.com", profile_id: 35934704}
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
   id: "merchantId", profile_id: 35934704}
```

### Deleting
```elixir
  > AuthorizeNet.Customer.delete 35934704
  :ok
```

## Errors

These errors might be raised by the API calls:

 * [AuthorizeNet.Error.Connection](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/error/connection_error.ex): There was an error when trying to hit the API endpoint (like a network issue).

 * [AuthorizeNet.Error.Request](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/error/request_error.ex): The request was sent and received by the server, but it returned a status different than 200.

 * [AuthorizeNet.Error.Operation](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/error/operation_error.ex): The request was sent and received successfully, a status 200 was returned by the server, but there was an error when trying to process the operation.