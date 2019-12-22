# Juice
[![Build Status](https://github.com/rupurt/juice/workflows/.github/workflows/test.yml/badge.svg)](https://github.com/rupurt/juice/actions?query=workflow%3A.github%2Fworkflows%2Ftest.yml)

Reduce in memory data structures using a lightweight query language

## Installation

Add `juice` to your list of dependencies in `mix.exs`

```elixir
def deps do
  [
    {:juice, "~> 0.0.3"}
  ]
end
```

## Usage

Juice can collect and reject string or atom keys from an Elixir [Map](https://hexdocs.pm/elixir/Map.html) or [List](https://hexdocs.pm/elixir/List.html).

Given the map

```elixir
iex> fruit_basket = %{
	apples: {
		granny_smith: 10,
		golden_delicious: 3
	},
	"oranges" => 5,
	plums: 6,
	"mangos" => 2,
	recipients: [:steph, "michael", :lebron, "charles"]
}
```

Return everything with a wildcard `*`

```elixir
iex> Juice.squeeze(fruit_basket, "*") == %{
	apples: {
		granny_smith: 10,
		golden_delicious: 3
	},
	"oranges" => 5,
	plums: 6,
	"mangos" => 2,
	recipients: [:steph, "michael", :lebron, "charles"]
}
```

Remove `plums` and `mangos`

```elixir
iex> Juice.squeeze(fruit_basket, "* -plums -mangos") == %{
	apples: {
		granny_smith: 10,
		golden_delicious: 3
	},
	"oranges" => 5,
	recipients: [:steph, "michael", :lebron, "charles"]
}
```

Only collect `granny_smith` `apples` and `oranges` with nested `.` notation

```elixir
iex> Juice.squeeze(fruit_basket, "apples.granny_smith oranges") == %{
	apples: {
		granny_smith: 10,
	},
	"oranges" => 5
}
```

Collect `plums` and `mangos` for `charles`

```elixir
iex> Juice.squeeze(fruit_basket, "plums mangos recipients.charles") == %{
	plums: 6,
	"mangos" => 2,
	recipients: ["charles"]
}
```
