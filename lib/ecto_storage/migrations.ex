defmodule EctoStorage.Migrations do
  @moduledoc """
  Migrations create and modify the database tables EctoStorage needs to function.

  ## Usage

  To use migrations in your application you'll need to generate an Ecto migration
  that wraps calls to `EctoStorage.Migrations`:

      mix ecto.gen.migration add_ecto_storage

  Open the generated migration in your editor and call the `up` and `down`
  functions on `EctoStorage.Migrations`:

      defmodule MyApp.Repo.Migrations.AddEctoStorage do
        use Ecto.Migration

        def up, do: EctoStorage.Migrations.up()

        def down, do: EctoStorage.Migrations.down()
      end

  Now, run the migration to create the tables:

      mix ecto.migrate

  ## Alternate Schemas

  EctoStorage supports namespacing through database schemas, also called "prefixes" in Ecto.
  To use a prefix you first have to specify it within your migration:

      defmodule MyApp.Repo.Migrations.AddEctoStorage do
        use Ecto.Migration

        def up, do: EctoStorage.Migrations.up(prefix: "private")

        def down, do: EctoStorage.Migrations.down(prefix: "private")
      end
  """

  use Ecto.Migration

  @doc """
  Run the up migration to create EctoStorage tables.
  """
  def up(opts \\ []) do
    prefix = opts[:prefix]

    create table(:ecto_storage_blobs, prefix: prefix) do
      add(:key, :string, null: false)
      add(:filename, :string, null: false)
      add(:content_type, :string)
      add(:byte_size, :integer)
      add(:checksum, :string)
      add(:service_name, :string, null: false)

      timestamps()
    end

    create table(:ecto_storage_attachment_ledgers, prefix: prefix) do
      add(:metadata, :map)

      timestamps()
    end

    create table(:ecto_storage_attachments, prefix: prefix) do
      add(:blob_id, references(:ecto_storage_blobs, on_delete: :delete_all), null: false)

      add(
        :ledger_id,
        references(:ecto_storage_attachment_ledgers, on_delete: :delete_all),
        null: false
      )

      timestamps()
    end

    # Indexes for performance
    create(unique_index(:ecto_storage_blobs, [:key], prefix: prefix))
    create(index(:ecto_storage_attachments, [:blob_id], prefix: prefix))
    create(index(:ecto_storage_attachments, [:ledger_id], prefix: prefix))
  end

  @doc """
  Run the down migration to drop EctoStorage tables.
  """
  def down(opts \\ []) do
    prefix = opts[:prefix]

    drop_if_exists(table(:ecto_storage_attachments, prefix: prefix))
    drop_if_exists(table(:ecto_storage_attachment_ledgers, prefix: prefix))
    drop_if_exists(table(:ecto_storage_blobs, prefix: prefix))
  end
end
