defmodule EctoStorage.Attachments.Blob do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ecto_storage_blobs" do
    field :key, :string
    field :filename, :string
    field :content_type, :string
    field :byte_size, :integer
    field :checksum, :string
    field :service_name, :string

    has_many :attachments, EctoStorage.Attachments.Attachment

    timestamps()
  end

  def changeset(blob, attrs) do
    blob
    |> cast(attrs, [:key, :filename, :content_type, :byte_size, :checksum, :service_name])
    |> validate_required([:key, :filename, :service_name])
  end
end
