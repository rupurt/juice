defmodule Juice do
  @moduledoc """
  Reduce in memory data structures using a lightweight query language
  """

  alias Juice.Expression

  def squeeze(enum, query) when is_bitstring(query) do
    expression = Expression.parse(query)
    squeeze(enum, expression)
  end

  def squeeze(%{} = source, expression) when is_list(expression) do
    expression
    |> Enum.reduce(%{}, fn operation, acc ->
      case operation do
        {:+, ["*"]} -> source
        {:-, ["*"]} -> %{}
        {:+, key_chain} -> collect(key_chain, source, acc)
        {:-, key_chain} -> reject(key_chain, acc)
      end
    end)
  end

  defp collect([key | []], source, acc) do
    sub_source = Map.get(source, key)

    Map.put(acc, key, sub_source)
  end

  defp collect([key | tail], source, acc) do
    sub_source = Map.get(source, key)
    sub_acc = collect(tail, sub_source, acc)

    Map.put(acc, key, sub_acc)
  end

  defp reject([key | []], acc) do
    Map.delete(acc, key)
  end

  defp reject([key | tail], acc) do
    sub_acc = Map.get(acc, key)
    rejected = reject(tail, sub_acc)

    Map.put(acc, key, rejected)
  end
end
