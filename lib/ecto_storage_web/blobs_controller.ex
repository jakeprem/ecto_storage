defmodule EctoStorageWeb.BlobsController do
  use Phoenix.Controller, formats: []
  
  @moduledoc """
  Phoenix controller for serving blobs in proxy mode.
  
  Proxies blob content through the application rather than redirecting
  to storage backend URLs.
  """

  alias EctoStorage.Attachments.Blob

  def proxy(conn, %{"id" => id} = params) do
    repo = Application.get_env(:ecto_storage, :repo)
    
    case repo.get(Blob, id) do
      nil ->
        send_error(conn, 404, "Blob not found")
      
      blob ->
        case EctoStorage.Storage.LocalStorage.get(blob.key) do
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