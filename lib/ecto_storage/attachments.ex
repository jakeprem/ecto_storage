defmodule EctoStorage.Attachments do
  @moduledoc false

  alias EctoStorage.Attachments.{Attachment, Ledger, Blob}

  defp storage_module,
    do: Application.get_env(:ecto_storage, :storage_module, EctoStorage.Storage.LocalStorage)

  defp repo, do: Application.get_env(:ecto_storage, :repo)

  def attach(record, field, source) do
    repo = repo()

    with :ok <- validate_preloads(record, field),
         {:ok, blob} <- create_blob(repo, source),
         {:ok, ledger} <- ensure_ledger(repo, record, field),
         {:ok, attachment} <-
           upsert_attachment(repo, ledger, blob, current_attachment(record, field)) do
      {:ok, attachment}
    end
  end

  defp validate_preloads(record, field) do
    required_fields = [:"#{field}_ledger", field]

    missing_fields =
      Enum.filter(required_fields, fn f ->
        match?(%Ecto.Association.NotLoaded{}, Map.get(record, f))
      end)

    case missing_fields do
      [] -> :ok
      fields -> raise "Must preload #{Enum.join(fields, ", ")} before calling attach/3"
    end
  end

  defp current_attachment(record, field), do: Map.get(record, field)

  defp create_blob(repo, %{file_path: path, filename: name, content_type: type, size: size}) do
    with {:ok, key} <- storage_module().store(path) do
      %Blob{}
      |> Blob.changeset(%{
        key: key,
        filename: name,
        content_type: type,
        byte_size: size,
        service_name: "local"
      })
      |> repo.insert()
    end
  end

  defp ensure_ledger(repo, record, field) do
    case Map.get(record, :"#{field}_ledger") do
      nil -> create_ledger(repo, record, field)
      ledger -> {:ok, ledger}
    end
  end

  defp create_ledger(repo, record, field) do
    ledger_field = :"#{field}_ledger"
    ledger_attrs = %{
      metadata: %{
        record_type: to_string(record.__struct__),
        record_id: record.id,
        field: to_string(field)
      }
    }

    case record
         |> Ecto.Changeset.cast(%{ledger_field => ledger_attrs}, [])
         |> Ecto.Changeset.cast_assoc(ledger_field)
         |> repo.update() do
      {:ok, updated_record} -> {:ok, Map.get(updated_record, ledger_field)}
      error -> error
    end
  end

  defp upsert_attachment(repo, ledger, new_blob, nil),
    do: create_attachment(repo, ledger.id, new_blob.id)

  defp upsert_attachment(repo, _ledger, new_blob, %Attachment{} = attachment) do
    with {:ok, updated} <- update_attachment(repo, attachment, new_blob.id) do
      EctoStorage.BlobCleanup.cleanup_blob_id(attachment.blob_id)
      {:ok, updated}
    end
  end

  defp create_attachment(repo, ledger_id, blob_id) do
    %Attachment{}
    |> Attachment.changeset(%{ledger_id: ledger_id, blob_id: blob_id})
    |> repo.insert()
  end

  defp update_attachment(repo, attachment, blob_id) do
    attachment
    |> Attachment.changeset(%{blob_id: blob_id})
    |> repo.update()
  end
end
