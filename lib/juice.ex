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
      empty_acc(source),
      &eval(source, &1, &2)
    )
  end

  defp eval(source, {:+, ["*"]}, _), do: source
  defp eval(source, {:-, ["*"]}, _), do: empty_acc(source)

  defp eval(source, {:+, key_chain}, acc) do
    collect(key_chain, source, acc)
  end

  defp eval(_, {:-, key_chain}, acc) do
    reject(key_chain, acc)
  end

  defp collect([key | []], source, acc) when is_list(source) and is_list(acc) do
    cond do
      Enum.member?(source, key) ->
        collect_intersection(key, source, acc)

      Enum.member?(source, key |> String.to_atom()) ->
        collect_intersection(key |> String.to_atom(), source, acc)

      true ->
        []
    end
  end

  defp collect([key | []], source, acc) when is_map(source) and is_map(acc) do
    sub_source = Map.get(source, key)
    Map.put(acc, key, sub_source)
  end

  defp collect([key | tail], source, acc) when is_map(source) and is_map(acc) do
    {matched_key, sub_source} = match(key, source)

    default_acc = empty_acc(sub_source)
    sub_acc = Map.get(acc, matched_key, default_acc)
    collected = collect(tail, sub_source, sub_acc)

    Map.put(acc, matched_key, collected)
  end

  defp collect_intersection(key, source, acc) do
    source_set = MapSet.new(source)
    acc_set = MapSet.new([key | acc])

    source_set
    |> MapSet.intersection(acc_set)
    |> MapSet.to_list()
  end

  defp match(key, source) do
    atom_key = String.to_atom(key)

    cond do
      Map.has_key?(source, atom_key) ->
        {atom_key, Map.get(source, atom_key)}

      true ->
        {key, Map.get(source, key)}
    end
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
