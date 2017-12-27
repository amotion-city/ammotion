defmodule Ammo.Helpers.Ecto do
  defmacro __using__(opts \\ []) do
    fields = opts[:fields]
    quote do
      import Ecto.Changeset
      @type t :: Ecto.Schema.t

      @doc "Returns a changeset"
      def new?(attrs) when is_list(attrs) do
        attrs
        |> Keyword.take(unquote(fields))
        |> Enum.into(%{})
        |> new?()
      end
      def new?(attrs) when is_map(attrs),
        do: changeset(%__MODULE__{}, attrs)

      @doc "Returns an in-memory object"
      def new(attrs), do: attrs |> new?() |> apply_changes()
      @doc "Persists an object"
      def new!(attrs) do
        case attrs |> new?() |> Ammo.Repo.insert() do
          {:ok, photo} -> # %__MODULE__{} = photo} ->
            photo
          {:error, %{errors: errors}} ->
            {:error, errors |> Enum.map(fn {k, {msg, _}} -> "#{k}: #{msg}" end)}
        end
      end
    end
  end
end
