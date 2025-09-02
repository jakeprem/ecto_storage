defmodule EctoStorageWeb do
  @moduledoc """
  Router helpers for EctoStorage blob serving.
  """

  defmacro blob_routes(path \\ "/blobs", opts \\ []) do
    quote bind_quoted: [path: path, opts: opts] do
      scope path, alias: false, as: false do
        pipe_through Keyword.get(opts, :pipe_through, [:browser])
        
        # Match ActiveStorage pattern but with plain IDs for now
        get "/proxy/:id/*filename", EctoStorageWeb.BlobsController, :proxy, as: :blob_proxy
        get "/proxy/:id", EctoStorageWeb.BlobsController, :proxy, as: :blob_proxy
      end
    end
  end
end