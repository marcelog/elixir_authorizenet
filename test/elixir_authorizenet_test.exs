defmodule AuthorizeNetTest do
  use ExUnit.Case
  use Servito
  use AuthorizeNet.Test.Util

  setup do
    :timer.sleep 100
    :ok
  end
  test "can raise connection error on network issues" do
    assert_raise AuthorizeNet.Error.Connection, &AuthorizeNet.Customer.get_all/0
  end

  test "can raise request error on server issues" do
    start_server fn(_bindings, _headers, _body, req, state) ->
      ret 404, [], "blah"
    end
    assert_raise AuthorizeNet.Error.Connection, &AuthorizeNet.Customer.get_all/0
    stop_server
  end

  test "can raise operation error on bad request" do
    start_server fn(_bindings, _headers, _body, req, state) ->
      serve_file "bad_auth"
    end
    assert_raise AuthorizeNet.Error.Operation, &AuthorizeNet.Customer.get_all/0
    stop_server
  end

  test "can get all customer profiles" do
    start_server fn(_bindings, _headers, _body, req, state) ->
      serve_file "customer_profiles_get_all"
    end
    assert [35934704] === AuthorizeNet.Customer.get_all
    stop_server
  end

  test "can get customer profile" do
    start_server fn(_bindings, _headers, _body, req, state) ->
      serve_file "customer_profile_get"
    end
    assert [
      description: "description",
      email: "email2@host.com",
      merchantCustomerId: "merchantId",
      customerProfileId: 35934704
    ] === AuthorizeNet.Customer.get 35934704
    stop_server
  end

  test "cant get inexistant profile" do
    start_server fn(_bindings, _headers, _body, req, state) ->
      serve_file "get_inexistant_customer_profile"
    end
    try do
      AuthorizeNet.Customer.get 35934705
      flunk "expected to fail"
    rescue
      e in AuthorizeNet.Error.Operation ->
        assert e.message === [{"E00040", "The record cannot be found."}]
    end
    stop_server
  end

  test "can create customer profile" do
    start_server fn(_bindings, _headers, _body, req, state) ->
      serve_file "create_customer_profile"
    end
    assert [
      customerProfileId: 35934704,
      merchantCustomerId: "merchantId",
      description: "description",
      email: "email@host.com"
    ] === AuthorizeNet.Customer.create "merchantId", "description", "email@host.com"
    stop_server
  end

  test "cant create duplicated customer profile" do
    start_server fn(_bindings, _headers, _body, req, state) ->
      serve_file "create_duplicated_customer_profile"
    end
    try do
      AuthorizeNet.Customer.create "merchantId", "description", "email@host.com"
      flunk "expected to fail"
    rescue
      e in AuthorizeNet.Error.Operation ->
        assert e.message === [{"E00039", "A duplicate record with ID 35938239 already exists."}]
    end
    stop_server
  end

  test "can update duplicate customer profile" do
    start_server fn(_bindings, _headers, _body, req, state) ->
      serve_file "update_customer_profile"
    end
    assert [
      merchantCustomerId: "merchantId2",
      description: "description2",
      email: "email2@host.com",
      customerProfileId: 35934704
    ] === AuthorizeNet.Customer.update(
      35934704, "merchantId2", "description2", "email2@host.com"
    )
    stop_server
  end

  test "can delete customer profile" do
    start_server fn(_bindings, _headers, _body, req, state) ->
      serve_file "delete_customer_profile"
    end
    :ok = AuthorizeNet.Customer.delete 35934704
    stop_server
  end
end
