defmodule EctoStorage.Config do
  @moduledoc false

  def repo, do: Application.get_env(:ecto_storage, :repo)

  def storage_module,
    do: get_var(:storage_module, EctoStorage.Storage.LocalStorage)

  def blob_cleanup,
    do: get_var(:blob_cleanup, EctoStorage.BlobCleanup.Sync)

  defp get_var(var, default) do
    Application.get_env(:ecto_storage, var, default)
  end
end

