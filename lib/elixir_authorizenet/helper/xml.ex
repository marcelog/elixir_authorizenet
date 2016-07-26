defmodule AuthorizeNet.Helper.XML do
  @moduledoc """
  "Low-level" XML helper. Move on, nothing to see here :)

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

  defmacro __using__(_opts) do
    quote do
      import AuthorizeNet.Helper.XML
      require Record
      require Logger
      Record.defrecord(
        :xmlText,
        Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")
      )
      Record.defrecord(
        :xmlElement,
        Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
      )
    end
  end

  defmacro xml_find(doc, xpath) do
    quote [location: :keep] do
      Exmerl.XPath.find unquote(doc), unquote(xpath)
    end
  end

  defmacro xml_value(doc, element) do
    quote [location: :keep] do
      elements = xml_find unquote(doc), "#{unquote(element)}/text()"
      for e <- elements, do: to_string xmlText(e, :value)
    end
  end

  defmacro xml_one_value_int(doc, element) do
    quote [location: :keep] do
      case xml_one_value(unquote(doc), unquote(element)) do
        nil -> nil
        code ->
          {code, ""} = Integer.parse code
          code
      end
    end
  end

  defmacro xml_one_value(doc, element) do
    quote [location: :keep] do
      case xml_find unquote(doc), "#{unquote(element)}/text()" do
        [] -> nil
        elements ->
          strings = for e <- elements, do: to_string xmlText(e, :value)
          Enum.join strings, ""
      end
    end
  end
end