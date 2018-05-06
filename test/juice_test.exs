defmodule JuiceTest do
  use ExUnit.Case, async: true
  doctest Juice

  test "applies each segment of the expression in sequence" do
    map = %{
      "a" => %{
        "b" => %{"c" => %{"d" => %{}}},
        "c" => %{"d" => %{}},
        "d" => %{}
      },
      "b" => %{
        "c" => %{"d" => %{}},
        "d" => %{}
      },
      "c" => %{"d" => %{}},
      "d" => %{}
    }

    assert Juice.squeeze(map, "") == %{}

    assert Juice.squeeze(map, "*") == %{
             "a" => %{
               "b" => %{"c" => %{"d" => %{}}},
               "c" => %{"d" => %{}},
               "d" => %{}
             },
             "b" => %{
               "c" => %{"d" => %{}},
               "d" => %{}
             },
             "c" => %{"d" => %{}},
             "d" => %{}
           }

    assert Juice.squeeze(map, "* -*") == %{}

    assert Juice.squeeze(map, "a") == %{
             "a" => %{
               "b" => %{"c" => %{"d" => %{}}},
               "c" => %{"d" => %{}},
               "d" => %{}
             }
           }

    assert Juice.squeeze(map, "a -a") == %{}

    assert Juice.squeeze(map, "a.b") == %{
             "a" => %{
               "b" => %{"c" => %{"d" => %{}}}
             }
           }

    assert Juice.squeeze(map, "a.b -a.b") == %{"a" => %{}}
  end
end
