# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#

alias Ammo.Repo, as: R
alias Ammo.{User,Photo,Album}

R.insert!(%User{name: "Aleksei", email: "am@amotion.city"})
Photo.new! %{user_id: R.one(User).id, caption: "Hello, world!", image: %Plug.Upload{filename: "1.jpg", path: "images/1.jpg"}}

