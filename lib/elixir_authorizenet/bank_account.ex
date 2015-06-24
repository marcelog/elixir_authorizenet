defmodule AuthorizeNet.BankAccount do
  @moduledoc """
  Bank account information for payment profiles and other transactions.
  """
  use AuthorizeNet.Helper.XML
  @echeck_type [
    ccd: "CCD",
    ppd: "PPD",
    tel: "TEL",
    web: "WEB"
  ]

  @account_type [
    savings: "savings",
    checking: "checking",
    business_checking: "businessChecking"
  ]

  defstruct type: nil,
    routing_number: nil,
    account_number: nil,
    name_on_account: nil,
    echeck_type: nil,
    bank_name: nil

  @type t :: %AuthorizeNet.BankAccount{}
  @type echeck_type :: :ccd | :ppd | :tel | :web
  @type account_type :: :savings | :checking | :business_checking

  @doc """
  Creates a new savings account.
  """
  @spec savings(
    String.t, String.t, String.t, String.t,
    AuthorizeNet.BankAccount.echeck_type
  ) :: AuthorizeNet.BankAccount.t | no_return
  def savings(
    bank_name, routing_number, account_number, name_on_account, echeck_type
  ) do
    new(
      :savings, bank_name, routing_number,
      account_number, name_on_account, echeck_type
    )
  end

  @doc """
  Creates a new checking account.
  """
  @spec checking(
    String.t, String.t, String.t, String.t,
    AuthorizeNet.BankAccount.echeck_type
  ) :: AuthorizeNet.BankAccount.t | no_return
  def checking(
    bank_name, routing_number, account_number, name_on_account, echeck_type
  ) do
    new(
      :checking, bank_name, routing_number,
      account_number, name_on_account, echeck_type
    )
  end

  @doc """
  Creates a new business checking account.
  """
  @spec business_checking(
    String.t, String.t, String.t, String.t,
    AuthorizeNet.BankAccount.echeck_type
  ) :: AuthorizeNet.BankAccount.t | no_return
  def business_checking(
    bank_name, routing_number, account_number, name_on_account, echeck_type
  ) do
    new(
      :business_checking, bank_name, routing_number,
      account_number, name_on_account, echeck_type
    )
  end

  @spec new(
    String.t, String.t, String.t, String.t, String.t,
    AuthorizeNet.BankAccount.echeck_type
  ) :: AuthorizeNet.BankAccount.t | no_return
  defp new(
    type, bank_name, routing_number, account_number,
    name_on_account, echeck_type
  ) do
    if not echeck_type in Keyword.keys(@echeck_type) do
      raise ArgumentError, "Invalid echeck type, valid ones are: " <>
        "#{inspect Keyword.keys(@echeck_type)}"
    end
    if not echeck_type in Keyword.keys(@echeck_type) do
      raise ArgumentError, "Invalid echeck type, valid ones are: " <>
        "#{inspect Keyword.keys(@echeck_type)}"
    end
    %AuthorizeNet.BankAccount{
      type: type,
      routing_number: routing_number,
      account_number: account_number,
      name_on_account: name_on_account,
      echeck_type: echeck_type,
      bank_name: bank_name
    }
  end

  @doc """
  Renders the given bank account structure as a structure suitable to be
  rendered as xml.
  """
  @spec to_xml(AuthorizeNet.BankAccount.t) :: Keyword.t
  def to_xml(account) do
    [
      bankAccount: [
        accountType: @account_type[account.type],
        routingNumber: account.routing_number,
        accountNumber: account.account_number,
        nameOnAccount: account.name_on_account,
        echeckType: @echeck_type[account.echeck_type],
        bankName: account.bank_name
      ]
    ]
  end

  @doc """
  Builds a BankAccount from an xmlElement record.
  """
  @spec from_xml(Record) :: AuthorizeNet.BankAccount.t
  def from_xml(doc) do
    account_type = case xml_one_value(doc, "//accountType") do
      nil -> nil
      account_type ->
        [{account_type, _}] = Enum.filter @account_type, fn({_k, v}) ->
          v === account_type
        end
        account_type
    end
    echeck_type = case xml_one_value(doc, "//echeckType") do
      nil -> nil
      echeck_type ->
        [{echeck_type, _}] = Enum.filter @echeck_type, fn({_k, v}) ->
          v === echeck_type
        end
        echeck_type
    end
    new(
      account_type,
      xml_one_value(doc, "//bankName"),
      xml_one_value(doc, "//routingNumber"),
      xml_one_value(doc, "//accountNumber"),
      xml_one_value(doc, "//nameOnAccount"),
      echeck_type
    )
  end
end