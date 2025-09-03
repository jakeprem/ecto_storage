defmodule EctoStorage do
  @moduledoc """
  Documentation for `EctoStorage`.
  """

  @doc """
  Returns an anonymous function for use with Phoenix LiveView's consume_uploaded_entries/3.
  
  This function handles the conversion from Phoenix LiveView upload entries to the format
  expected by EctoStorage.Attachments.attach/3.

  ## Examples

      uploaded_files = consume_uploaded_entries(socket, :cover_image, EctoStorage.live_attach(post, :cover_image))
  """
  def live_attach(record, field) do
    fn %{path: path}, entry ->
      source = %{
        file_path: path,
        filename: entry.client_name,
        content_type: entry.client_type,
        size: entry.client_size
      }
      
      case EctoStorage.Attachments.attach(record, field, source) do
        {:ok, attachment} -> {:ok, attachment}
        {:error, reason} -> 
          IO.puts("Attach failed: #{inspect(reason)}")
          {:postpone, reason}
      end
    end
  end
end
