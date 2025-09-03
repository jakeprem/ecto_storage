defmodule EctoStorage.Storage.LocalStorage do
  @moduledoc false

  def store(file_path) do
    upload_dir = Application.get_env(:ecto_storage, :upload_dir, "priv/uploads")
    key = generate_key(file_path)
    dest_path = Path.join(upload_dir, key)
    
    with :ok <- ensure_upload_dir(upload_dir),
         :ok <- File.cp(file_path, dest_path) do
      {:ok, key}
    end
  end

  def get(key) do
    upload_dir = Application.get_env(:ecto_storage, :upload_dir, "priv/uploads")
    file_path = Path.join(upload_dir, key)
    
    case File.read(file_path) do
      {:ok, content} -> {:ok, content}
      {:error, reason} -> {:error, reason}
    end
  end

  def delete(key) do
    upload_dir = Application.get_env(:ecto_storage, :upload_dir, "priv/uploads")
    file_path = Path.join(upload_dir, key)
    
    case File.rm(file_path) do
      :ok -> :ok
      {:error, :enoent} -> :ok  # File already deleted
      {:error, reason} -> {:error, reason}
    end
  end

  defp generate_key(_file_path) do
    Ecto.UUID.generate()
  end

  defp ensure_upload_dir(dir) do
    case File.mkdir_p(dir) do
      :ok -> :ok
      {:error, reason} -> {:error, "Could not create upload directory: #{reason}"}
    end
  end
end