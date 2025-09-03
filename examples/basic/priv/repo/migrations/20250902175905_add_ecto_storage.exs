defmodule Basic.Repo.Migrations.AddEctoStorage do
  use Ecto.Migration

  def up, do: EctoStorage.Migrations.up()

  def down, do: EctoStorage.Migrations.down()
end
