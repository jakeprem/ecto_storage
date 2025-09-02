defmodule EctoStorage.Attachments do
  @moduledoc false
  
  import Ecto.Query
  alias EctoStorage.Attachments.{Attachment, Ledger, Blob}
  
  @storage_module EctoStorage.Storage.LocalStorage

  def attach(record, field, file_path) do
    repo = Application.get_env(:ecto_storage, :repo)
    
    repo.transaction(fn ->
      with {:ok, blob} <- create_blob(file_path),
           {:ok, ledger} <- get_or_create_ledger(record, field),
           {:ok, attachment} <- create_attachment(ledger, blob) do
        attachment
      else
        {:error, reason} -> repo.rollback(reason)
      end
    end)
  end

  defp create_blob(file_path) do
    repo = Application.get_env(:ecto_storage, :repo)
    
    with {:ok, file_info} <- get_file_info(file_path),
         {:ok, key} <- @storage_module.store(file_path) do
      
      %Blob{}
      |> Blob.changeset(%{
        key: key,
        filename: file_info.filename,
        content_type: file_info.content_type,
        byte_size: file_info.size,
        checksum: file_info.checksum,
        service_name: "local"
      })
      |> repo.insert()
    end
  end

  defp get_or_create_ledger(record, field) do
    repo = Application.get_env(:ecto_storage, :repo)
    ledger_field_id = :"#{field}_ledger_id"
    
    case Map.get(record, ledger_field_id) do
      nil -> create_ledger(record, field)
      ledger_id -> {:ok, repo.get!(Ledger, ledger_id)}
    end
  end

  defp create_ledger(record, field) do
    repo = Application.get_env(:ecto_storage, :repo)
    
    ledger_attrs = %{
      metadata: %{
        record_type: to_string(record.__struct__),
        record_id: record.id,
        field: to_string(field)
      }
    }
    
    with {:ok, ledger} <- %Ledger{} |> Ledger.changeset(ledger_attrs) |> repo.insert(),
         {:ok, _updated_record} <- update_record_with_ledger(record, field, ledger.id) do
      {:ok, ledger}
    end
  end

  defp update_record_with_ledger(record, field, ledger_id) do
    repo = Application.get_env(:ecto_storage, :repo)
    ledger_field_id = :"#{field}_ledger_id"
    
    record
    |> Ecto.Changeset.change(%{ledger_field_id => ledger_id})
    |> repo.update()
  end

  defp create_attachment(ledger, blob) do
    repo = Application.get_env(:ecto_storage, :repo)
    
    %Attachment{}
    |> Attachment.changeset(%{
      name: blob.filename,
      ledger_id: ledger.id,
      blob_id: blob.id
    })
    |> repo.insert()
  end

  defp get_file_info(file_path) do
    with {:ok, stat} <- File.stat(file_path),
         {:ok, data} <- File.read(file_path) do
      
      filename = Path.basename(file_path)
      content_type = get_content_type(filename)
      checksum = :crypto.hash(:md5, data) |> Base.encode16(case: :lower)
      
      {:ok, %{
        filename: filename,
        content_type: content_type,
        size: stat.size,
        checksum: checksum
      }}
    end
  end

  defp get_content_type(filename) do
    case Path.extname(filename) do
      ".jpg" -> "image/jpeg"
      ".jpeg" -> "image/jpeg"
      ".png" -> "image/png"
      ".gif" -> "image/gif"
      ".pdf" -> "application/pdf"
      ".txt" -> "text/plain"
      _ -> "application/octet-stream"
    end
  end
end
