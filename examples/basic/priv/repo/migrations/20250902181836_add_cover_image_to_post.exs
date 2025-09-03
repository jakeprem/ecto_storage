defmodule Basic.Repo.Migrations.AddCoverImageToPost do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :cover_image_ledger_id, references(:ecto_storage_attachment_ledgers)
    end
  end
end
