defmodule AuthorizeNet.Address do
  def new(first_name, last_name, address, city, state, zip, country) do
    %{
      firstName: first_name,
      lastName: last_name,
      address: address,
      city: city,
      state: state,
      zip: zip,
      country: country
    }
  end
end
