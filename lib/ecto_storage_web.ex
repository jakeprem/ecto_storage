defmodule EctoStorageWeb do
  @moduledoc """
  Router helpers for EctoStorage blob serving.
  """

  defmacro blob_routes(path \\ "/blobs", opts \\ []) do
    opts =
      if Macro.quoted_literal?(opts) do
        Macro.prewalk(opts, &expand_alias(&1, __CALLER__))
      else
        opts
      end

    quote bind_quoted: [path: path, opts: opts] do
      scope path, alias: false, as: false do
        # Match ActiveStorage pattern but with plain IDs for now
        get "/proxy/:id/*filename", EctoStorageWeb.BlobsController, :proxy, as: :blob_proxy
        get "/proxy/:id", EctoStorageWeb.BlobsController, :proxy, as: :blob_proxy
      end
    end
  end

  defp expand_alias({:__aliases__, _, _} = alias, env),
    do: Macro.expand(alias, %{env | function: {:__blob_routes__, 2}})

  defp expand_alias(other, _env), do: other
end

