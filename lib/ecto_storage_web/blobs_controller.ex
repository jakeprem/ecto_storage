defmodule EctoStorageWeb.BlobsController do
  use Phoenix.Controller, formats: []
  
  @moduledoc """
  Phoenix controller for serving blobs in proxy mode.
  
  Proxies blob content through the application rather than redirecting
  to storage backend URLs.
  """

  alias EctoStorage.Attachments.Blob
  alias EctoStorage.Config

  def proxy(conn, %{"id" => id} = params) do
    repo = Config.repo()
    
    case repo.get(Blob, id) do
      nil ->
        send_error(conn, 404, "Blob not found")
      
      blob ->
        storage_module = Config.storage_module()

        case storage_module.get(blob.key) do
          {:ok, content} ->
            filename = get_filename(blob, params)
            
            conn
            |> put_resp_content_type(blob.content_type || "application/octet-stream")
            |> put_resp_header("content-disposition", "inline; filename=\"#{filename}\"")
            |> send_resp(200, content)
          
          {:error, _reason} ->
            send_error(conn, 404, "File not found")
        end
    end
  end

  def redirect(conn, %{"id" => id} = _params) do
    repo = Config.repo()

    case repo.get(Blob, id) do
      nil ->
        send_error(conn, 404, "Blob not found")

      blob ->
        # Generate storage URL and redirect to it
        storage_module = Config.storage_module()
        storage_url = storage_module.public_url(blob.key)
        Phoenix.Controller.redirect(conn, external: storage_url)
    end
  end

  defp get_filename(blob, params) do
    # Use filename from URL path if present, otherwise use blob's filename
    case params["filename"] do
      [filename] when is_binary(filename) -> URI.decode(filename)
      filename when is_binary(filename) -> URI.decode(filename)
      _ -> blob.filename
    end
  end

  defp send_error(conn, status, message) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(status, message)
  end
end