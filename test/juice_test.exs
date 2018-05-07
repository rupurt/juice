defmodule JuiceTest do
  use ExUnit.Case, async: true
  doctest Juice

  setup do
    map = %{
      "a" => %{
        "b" => %{"c" => %{"d" => ["A", "B", "C", "D"]}},
        "c" => %{"d" => []},
        "d" => []
      },
      "b" => %{
        "c" => %{"d" => []},
        "d" => []
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
               "d" => []
             },
             "b" => %{
               "c" => %{"d" => []},
               "d" => []
             },
             "c" => %{"d" => []},
             "d" => []
           }
  end

  test "returns an empty map on a negated wildcard", %{map: map} do
    assert Juice.squeeze(map, "* -*") == %{}
  end

  test "can nest keys with dot notation", %{map: map} do
    assert Juice.squeeze(map, "a") == %{
             "a" => %{
               "b" => %{"c" => %{"d" => ["A", "B", "C", "D"]}},
               "c" => %{"d" => []},
               "d" => []
             }
           }

    assert Juice.squeeze(map, "a.b") == %{
             "a" => %{
               "b" => %{"c" => %{"d" => ["A", "B", "C", "D"]}}
             }
           }
  end

  test "merges siblings" do
    map = %{
      "a" => %{
        "b" => "B",
        "c" => "C",
        "d" => "D"
      }
    }

    assert Juice.squeeze(map, "a.b a.c") == %{
             "a" => %{
               "b" => "B",
               "c" => "C"
             }
           }
  end

  test "can negate keys", %{map: map} do
    assert Juice.squeeze(map, "a -a") == %{}
    assert Juice.squeeze(map, "a.b -a.b") == %{"a" => %{}}

    assert Juice.squeeze(map, "a -a.b -a.c") == %{
             "a" => %{
               "d" => []
             }
           }
  end

  test "can match keys in a list", %{map: map} do
    assert Juice.squeeze(map, "a.b.c.d.A") == %{
             "a" => %{
               "b" => %{"c" => %{"d" => ["A"]}}
             }
           }

    assert Juice.squeeze(map, "a.b.c.d.A a.b.c.d.B a.b.c.d.C") == %{
             "a" => %{
               "b" => %{"c" => %{"d" => ["A", "B", "C"]}}
             }
           }
  end

  test "can negate keys in a list", %{map: map} do
    assert Juice.squeeze(map, "a.b.c.d.A a.b.c.d.B -a.b.c.d.B") == %{
             "a" => %{
               "b" => %{"c" => %{"d" => ["A"]}}
             }
           }
  end

  test "can match on a top level list" do
    list = ["a", "b", "c", "d"]

    assert Juice.squeeze(list, "a b") == ["a", "b"]
  end

  test "can match symbols" do
    list = [:a, :b, :c, :d]

    map = %{
      a: [:alex, :alfred],
      b: [:ben, :bonnie],
      c: [:charles, :candy]
    }

    assert Juice.squeeze(list, "a b") == [:a, :b]

    assert Juice.squeeze(map, "a.alex b.ben") == %{
             a: [:alex],
             b: [:ben]
           }
  end
end
