defmodule Juice do
  @moduledoc """
  Reduce in memory data structures using a lightweight query language
  """

  alias Juice.Expression

  def squeeze(source, query) when is_bitstring(query) do
    expression = Expression.parse(query)
    squeeze(source, expression)
  end

  def squeeze(source, expression) when is_list(expression) do
    expression
    |> Enum.reduce(
      %{},
      &eval(source, &1, &2)
    )
  end

  defp eval(source, {:+, ["*"]}, _), do: source
  defp eval(_, {:-, ["*"]}, _), do: %{}

  defp eval(source, {:+, key_chain}, acc) do
    key_chain
    |> collect(source, acc)
  end

  defp eval(_, {:-, key_chain}, acc) do
    key_chain
    |> reject(acc)
  end

  defp collect([key | []], source, acc) when is_list(source) do
    if Enum.member?(source, key) do
      source_set = MapSet.new(source)
      acc_set = MapSet.new([key | acc])

      source_set
      |> MapSet.intersection(acc_set)
      |> MapSet.to_list()
    end
  end

  defp collect([key | []], source, acc) when is_map(source) do
    sub_source = Map.get(source, key)
    Map.put(acc, key, sub_source)
  end

  defp collect([key | tail], source, acc) when is_map(source) do
    sub_source = Map.get(source, key)
    default_acc = empty_acc(sub_source)
    sub_acc = Map.get(acc, key, default_acc)
    collected = collect(tail, sub_source, sub_acc)

    Map.put(acc, key, collected)
  end

  defp reject([key | []], acc) when is_list(acc) do
    acc
    |> List.delete(key)
  end

  defp reject([key | []], acc) when is_map(acc) do
    Map.delete(acc, key)
  end

  defp reject([key | tail], acc) when is_map(acc) do
    sub_acc = Map.get(acc, key)
    rejected = reject(tail, sub_acc)
    Map.put(acc, key, rejected)
  end

  defp empty_acc(source) when is_map(source), do: %{}
  defp empty_acc(source) when is_list(source), do: []
end
