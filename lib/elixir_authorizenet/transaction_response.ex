defmodule AuthorizeNet.TransactionResponse do
  @moduledoc """
  Transaction response.

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
  use AuthorizeNet.Helper.XML
  defstruct code: nil,
    auth_code: nil,
    avs_result: nil,
    cvv_result: nil,
    cavv_result: nil,
    transaction_id: nil,
    ref_transaction_id: nil,
    transaction_hash: nil,
    test_request: nil,
    account_number: nil,
    account_type: nil,
    errors: [],
    user_fields: [],
    success: nil,
    operation_errors: []

  def new(doc) do
    code = xml_one_value_int doc, "//responseCode"
    success = (xml_one_value(doc, "//resultCode") !== "Error") and (code === 1)
    codes = xml_value doc, "//code"
    texts = xml_value doc, "//text"
    user_fields = case xml_find doc, ~x"//userField"l do
      [] -> []
      user_fields -> for f <- user_fields do
        {xml_one_value(f, "//name"), xml_one_value(f, "//value")}
      end
    end
    error_codes = xml_value doc, "//errorCode"
    error_texts = xml_value doc, "//errorText"
    %AuthorizeNet.TransactionResponse{
      operation_errors: Enum.zip(error_codes, error_texts),
      errors: Enum.zip(codes, texts),
      success: success,
      code: code,
      user_fields: user_fields,
      transaction_id: xml_one_value(doc, "//transId"),
      ref_transaction_id: xml_one_value(doc, "//refTransID"),
      transaction_hash: xml_one_value(doc, "//transHash"),
      account_type: xml_one_value(doc, "//accountType"),
      account_number: xml_one_value(doc, "//accountNumber"),
      cvv_result: xml_one_value(doc, "//cvvResultCode"),
      cavv_result: xml_one_value(doc, "//cavvResultCode"),
      auth_code: xml_one_value(doc, "//authCode"),
      avs_result: xml_one_value(doc, "//avsResultCode"),
      test_request: xml_one_value(doc, "//testRequest")
    }
  end
end