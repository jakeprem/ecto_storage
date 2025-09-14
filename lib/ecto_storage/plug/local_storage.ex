defmodule EctoStorage.Plug.LocalStorage do
  @moduledoc """
  A plug pipeline for serving local storage files.

  Reads configuration from EctoStorage.Storage.LocalStorage and sets up
  a pipeline that can handle both public and private (signed) file serving.

  ## Usage

      # In your endpoint.ex
      plug EctoStorage.Plug.LocalStorage

  ## Configuration

      config :ecto_storage, EctoStorage.Storage.LocalStorage,
        upload_dir: {:my_app, "uploads"},  # or absolute path
        static_path: "/uploads"
  """

  use Plug.Builder

  # Get config at compile time
  @config Application.compile_env(:ecto_storage, EctoStorage.Storage.LocalStorage, [])
  @static_path Keyword.get(@config, :static_path, "/uploads")
  @upload_dir Keyword.get(@config, :upload_dir, "priv/uploads")

  # For now, just serve statically (public mode)
  # Later we can add signature validation plug before this
  plug(Plug.Static,
    at: @static_path,
    from: @upload_dir
  )
end

