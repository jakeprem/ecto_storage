defmodule EctoStorage.BlobCleanup do
  @moduledoc """
  Behaviour for blob cleanup strategies.

  Defines how and when blob files and records are cleaned up
  when attachments are removed or replaced.
  """
  alias EctoStorage.Attachments.Blob

  @callback cleanup_blob(blob :: EctoStorage.Attachments.Blob.t()) :: :ok | {:error, String.t()}

  @doc """
  Get the configured blob cleanup module.
  """
  def cleanup_module do
    EctoStorage.Config.blob_cleanup()
  end

  @doc """
  Clean up a blob using the configured cleanup strategy.
  """
  def cleanup_blob(%Blob{} = blob) do
    cleanup_module().cleanup_blob(blob)
  end

  def cleanup_blob_id(blob_id) do
    cleanup_module().cleanup_blob_id(blob_id)
  end
end
