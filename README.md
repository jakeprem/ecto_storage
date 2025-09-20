# EctoStorage

## What is it?

EctoStorage is meant to provide robust object storage capabilities for Ecto schemas.
It's heavily inspired by Rails's ActiveStorage while still trying to follow Ecto
patterns like avoiding the `record_id`, `record_type` polymorphism pattern.

To that end it (currently) uses a Ledger approach, where polymorphism is achieved by
adding a foreign key from the main table (e.g. Post) to the attachments ledger table.
Then all attachment records point to the ledger table, using it as a sort of constrained
join table.

See `/examples`

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ecto_storage` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_storage, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ecto_storage>.
