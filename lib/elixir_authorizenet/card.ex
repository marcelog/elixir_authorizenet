defmodule AuthorizeNet.Card do
  @moduledoc """
  Credit card information for payment profiles and other transactions.
  """
  use AuthorizeNet.Helper.XML

  defstruct number: nil,
    expiration_date: nil,
    code: nil

  @type t :: %AuthorizeNet.Card{}

  @doc """
  Creates a new Card structure. The expiration date is in the form: YYYY-MM.
  """
  @spec new(String.t, String.t, String.t) :: AuthorizeNet.Card.t
  def new(number, expiration_date, code) do
    %AuthorizeNet.Card{
      number: number,
      expiration_date: expiration_date,
      code: code
    }
  end

  @doc """
  Renders the given card structure as a structure suitable to be rendered as
  xml.
  """
  @spec to_xml(AuthorizeNet.Card.t) :: Keyword.t
  def to_xml(card) do
    [
      creditCard: [
        cardNumber: card.number,
        expirationDate: card.expiration_date,
        cardCode: card.code
      ]
    ]
  end

  @doc """
  Builds an Card from an xmlElement record.
  """
  @spec from_xml(Record) :: AuthorizeNet.Card.t
  def from_xml(doc) do
    new(
      xml_one_value(doc, "//cardNumber"),
      xml_one_value(doc, "//expirationDate"),
      xml_one_value(doc, "//cardCode")
    )
  end
end