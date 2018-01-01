import_file "~/.iex.exs"

case :application.get_key(:ammotion, :modules) do
  {:ok, modules} ->
    Application.put_env(:elixir, :ansi_enabled, true)
    IEx.configure(
    colors: [
      eval_result: [:green, :bright] ,
      eval_error: [[:red, :bright, "\n▶▶▶\n"]],
      eval_info: [:yellow, :bright],
    ],
    default_prompt: [
      "\e[G", # cursor ⇒ column 1
        :blue, "%prefix", :yellow, "|", :blue, "%counter", " ", :yellow, "▶", :reset
      ] |> IO.ANSI.format |> IO.chardata_to_string
    )

    alias Ammo.{Repo,User,Photo,Album}
    [am|_] = Repo.all User
  _ -> IO.puts("[NB] starting an `iex` alone; application :ammotion is not loaded!")
end
