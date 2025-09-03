defmodule EctoStorage.BlobCleanup.Sync do
  @moduledoc """
  Synchronous blob cleanup strategy.

  Immediately deletes files and blob records when cleanup is requested.
  Best for development environments or simple applications.
  """

  @behaviour EctoStorage.BlobCleanup

  def cleanup_blob_id(blob_id) do
    repo = Application.get_env(:ecto_storage, :repo)
    
    case repo.get(EctoStorage.Attachments.Blob, blob_id) do
      nil -> :ok  # Already deleted
      blob -> cleanup_blob(blob)
    end
  end

  def cleanup_blob(blob) do
    # Delete file from storage
    case EctoStorage.Storage.LocalStorage.delete(blob.key) do
      :ok ->
        # Delete blob record from database
        repo = Application.get_env(:ecto_storage, :repo)
        repo.delete(blob)

      {:error, reason} ->
        {:error, "Failed to delete file: #{reason}"}
    end
  end
end

