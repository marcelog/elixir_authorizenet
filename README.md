AuthorizeNet
============

Elixir client for the [Authorize.Net merchant API](http://developer.authorize.net/api/reference/index.html).
This is WIP.

## Customer Profiles

### Creating
```elixir
  > AuthorizeNet.Customer.create "merchantId", "description", "email@host.com"
  35926385
```

### Updating
```elixir
 > AuthorizeNet.Customer.update 35926385, "merchantId", "description", "email2@host.com"
 :ok
```

### Get all IDs
```elixir
  > AuthorizeNet.Customer.get_all
  [35926385]
```

### Get Customer Profile
```elixir
  > AuthorizeNet.Customer.get 35926385
  [description: "description", email: "email2@host.com", merchantCustomerId: "merchantId"]
```

### Deleting
```elixir
  > AuthorizeNet.Customer.delete 35926385
  :ok
```

## Errors

These errors might be raised by the API calls:

 * [AuthorizeNet.Error.Connection](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/error/connection_error.ex): There was an error when trying to hit the API endpoint (like a network issue).

 * [AuthorizeNet.Error.Request](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/error/request_error.ex): The request was sent and received by the server, but it returned a status different than 200.

 * [AuthorizeNet.Error.Operation](https://github.com/marcelog/elixir_authorizenet/blob/master/lib/elixir_authorizenet/error/operation_error.ex): The request was sent and received successfully, a status 200 was returned by the server, but there was an error when trying to process the operation.