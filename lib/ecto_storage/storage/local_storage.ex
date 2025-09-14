defmodule EctoStorage.Storage.LocalStorage do
  @moduledoc false

  defp config do
    Application.get_env(:ecto_storage, __MODULE__, [])
  end

  defp upload_dir do
    config = config()
    upload_dir = Keyword.get(config, :upload_dir, "priv/uploads")

    case upload_dir do
      {otp_app, path} ->
        Path.join(Application.app_dir(otp_app), path)
      path when is_binary(path) ->
        path
    end
  end

  def store(file_path) do
    dir = upload_dir()
    key = generate_key(file_path)
    dest_path = Path.join(dir, key)
    
    with :ok <- ensure_upload_dir(dir),
         :ok <- File.cp(file_path, dest_path) do
      {:ok, key}
    end
  end

  def get(key) do
    dir = upload_dir()
    file_path = Path.join(dir, key)
    
    case File.read(file_path) do
      {:ok, content} -> {:ok, content}
      {:error, reason} -> {:error, reason}
    end
  end

  def delete(key) do
    dir = upload_dir()
    file_path = Path.join(dir, key)
    
    case File.rm(file_path) do
      :ok -> :ok
      {:error, :enoent} -> :ok  # File already deleted
      {:error, reason} -> {:error, reason}
    end
  end

  def public_url(key, _opts \\ []) do
    config = config()
    static_path = Keyword.get(config, :static_path, "/uploads")
    "#{static_path}/#{key}"
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