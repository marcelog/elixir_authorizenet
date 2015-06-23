defmodule AuthorizeNet.Helper.XML do
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
end