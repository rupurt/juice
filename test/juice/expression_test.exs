defmodule Juice.ExpressionTest do
  use ExUnit.Case, async: true
  doctest Juice.Expression

  test "builds a list" do
    assert Juice.Expression.parse("") == []

    assert Juice.Expression.parse("* citrus citrus.lemons -citrus.oranges") == [
             {:+, ["*"]},
             {:+, ["citrus"]},
             {:+, ["citrus", "lemons"]},
             {:-, ["citrus", "oranges"]}
           ]
  end
end
