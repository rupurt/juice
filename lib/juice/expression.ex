defmodule Juice.Expression do
  @moduledoc """
  Builds a sequence of operations
  """

  def parse(query) do
    query
    |> String.split(" ", trim: true)
    |> Enum.map(&operation/1)
  end

  defp operation("-" <> segment), do: {:-, String.split(segment, ".")}
  defp operation(segment), do: {:+, String.split(segment, ".")}
end
