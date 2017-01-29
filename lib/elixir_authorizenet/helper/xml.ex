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
      import SweetXml
    end
  end

  defmacro xml_find(doc, xpath) do
    quote [location: :keep] do
      SweetXml.xpath unquote(doc), unquote(xpath)
    end
  end

  defmacro xml_value(doc, element) do
    quote [location: :keep] do
      SweetXml.xpath unquote(doc), ~x"#{unquote(element)}/text()"ls
    end
  end

  defmacro xml_one_value_int(doc, element) do
    quote [location: :keep] do
      case SweetXml.xpath unquote(doc), ~x"#{unquote(element)}/text()"I do
        0 -> nil
        i -> i
      end
    end
  end

  defmacro xml_one_value(doc, element) do
    quote [location: :keep] do
      case SweetXml.xpath unquote(doc), ~x"#{unquote(element)}/text()"ls do
        [] -> nil
        elements -> Enum.join elements, ""
      end
    end
  end
end