defmodule EctoStorage.Attachments.Attachment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ecto_storage_attachments" do
    field :name, :string
    belongs_to :ledger, EctoStorage.Attachments.Ledger
    belongs_to :blob, EctoStorage.Attachments.Blob
    
    timestamps()
  end

  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [:name, :ledger_id, :blob_id])
    |> validate_required([:ledger_id, :blob_id])
  end
end
