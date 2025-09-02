defmodule EctoStorage.Attachments.Ledger do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ecto_storage_attachment_ledgers" do
    field :metadata, :map

    has_many :attachments, EctoStorage.Attachments.Attachment

    timestamps()
  end

  def changeset(ledger, attrs) do
    ledger
    |> cast(attrs, [:metadata])
    |> validate_required([:metadata])
  end
end
