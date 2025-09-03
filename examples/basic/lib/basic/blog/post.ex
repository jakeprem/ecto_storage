defmodule Basic.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoStorage.Schema, only: [has_one_attached: 1]

  schema "posts" do
    field :title, :string
    field :body, :string

    has_one_attached :cover_image

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end
end
