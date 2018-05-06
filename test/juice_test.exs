defmodule JuiceTest do
  use ExUnit.Case, async: true
  doctest Juice

  setup do
    map = %{
      "a" => %{
        "b" => %{"c" => %{"d" => ["A", "B", "C", "D"]}},
        "c" => %{"d" => []},
        "d" => %{}
      },
      "b" => %{
        "c" => %{"d" => []},
        "d" => %{}
      },
      "c" => %{"d" => []},
      "d" => []
    }

    {:ok, %{map: map}}
  end

  test "returns an empty map when there is no query", %{map: map} do
    assert Juice.squeeze(map, "") == %{}
  end

  test "returns everything on a wildcard match", %{map: map} do
    assert Juice.squeeze(map, "*") == %{
             "a" => %{
               "b" => %{"c" => %{"d" => ["A", "B", "C", "D"]}},
               "c" => %{"d" => []},
               "d" => %{}
             },
             "b" => %{
               "c" => %{"d" => []},
               "d" => %{}
             },
             "c" => %{"d" => []},
             "d" => []
           }
  end

  test "returns an empty map on a negated wildcard", %{map: map} do
    assert Juice.squeeze(map, "* -*") == %{}
  end

  test "can return a subset of keys with dot notation", %{map: map} do
    assert Juice.squeeze(map, "a") == %{
             "a" => %{
               "b" => %{"c" => %{"d" => ["A", "B", "C", "D"]}},
               "c" => %{"d" => []},
               "d" => %{}
             }
           }

    assert Juice.squeeze(map, "a.b") == %{
             "a" => %{
               "b" => %{"c" => %{"d" => ["A", "B", "C", "D"]}}
             }
           }
  end

  test "can negate keys", %{map: map} do
    assert Juice.squeeze(map, "a -a") == %{}
    assert Juice.squeeze(map, "a.b -a.b") == %{"a" => %{}}
  end
end
