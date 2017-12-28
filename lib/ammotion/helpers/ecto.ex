defmodule Ammo.Helpers.Ecto do
  defmacro __using__(opts \\ []) do
    fields = opts[:fields]
    quote do
      import Ecto.Query
      import Ecto.Changeset
      @type t :: Ecto.Schema.t

      def scaffold!(%__MODULE__{}), do: %__MODULE__{}
      def fix_attrs!(attrs), do: attrs

      @doc "Returns a changeset"
      def new?(attrs) when is_list(attrs) do
        attrs
        |> Keyword.take(unquote(fields))
        |> Enum.into(%{})
        |> new?()
      end
      def new?(attrs) when is_map(attrs) do
        %__MODULE__{}
        |> scaffold!()
        |> changeset(fix_attrs!(attrs))
      end

      @doc "Returns an in-memory object"
      def new(attrs), do: attrs |> new?() |> apply_changes()
      @doc "Persists an object"
      def new!(attrs) do
        case attrs |> new?() |> Ammo.Repo.insert() do
          {:ok, %__MODULE__{} = photo} ->
            photo
          {:error, %{errors: errors}} ->
            {:error, errors |> Enum.map(fn {k, {msg, _}} -> "#{k}: #{msg}" end)}
        end
      end

      defoverridable [scaffold!: 1, fix_attrs!: 1]
    end
  end
end
