# ApiCommons

A small set of methods for faster REST Endpoint creation.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `api_commons` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:api_commons, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/api_commons>.



## How to use

### Model

```elixir
defmodule DemoProjectWeb.Entity do
  use Ecto.Changeset
  use ApiCommons.Model

  schema :entity do
    field :test, :string
  end

  def changeset(entity, attrs \\ %{}) do
    entity
    |> cast(attrs, [:test])
    |> validate_required([:test])
  end

  # ----
  # Error handling methods
  # that will be called 
  # -----------------------

  def error_to_json(key, value) do

  end

end
```


### Controllers

```elixir
defmodule DemoProjectWeb.TestController do
  use DemoProjectWeb, :controller
  use ApiCommons.Controller
  alias DemoProjectWeb.Repo.Entity, as: EntityRepository


  # Example endpoint
  def create(conn, params) do
    entity = EntityRepository.create(params)

    # Will call render_entity/3 when successfully created entity
    # When contains {:error, %{code: 1231, msg: "Some error message"}}, an error message will be returned
    process(conn, entity)
  end

  @doc """
  Will be called when entity retrieved, created, deleted or successfully accessed.
  
  Needs to be implemented, because it will be called by process/3.
  """
  def render_entity(conn, entity_or_entities, opts) do
    # Render a single entity
    conn
    |> render("entity.json", %{entity: entitiy_or_entities})
  end

end
```