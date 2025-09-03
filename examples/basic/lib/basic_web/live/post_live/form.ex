defmodule BasicWeb.PostLive.Form do
  use BasicWeb, :live_view

  alias Basic.Repo
  alias Basic.Blog
  alias Basic.Blog.Post

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage post records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="post-form" phx-change="validate" phx-submit="save">
        <div class="space-y-6">
          <.input field={@form[:title]} type="text" label="Title" />
          <.input field={@form[:body]} type="textarea" label="Body" rows="6" />
          
          <div class="space-y-2">
            <label class="block text-sm font-medium text-gray-700 mb-2">Cover Image</label>
            
            <%= if @post.cover_image_blob && @live_action == :edit do %>
              <div class="mb-4 p-4 bg-gray-50 rounded-lg">
                <p class="text-sm text-gray-600 mb-2">Current cover image:</p>
                <img src={~p"/blobs/proxy/#{@post.cover_image_blob.id}/#{@post.cover_image_blob.filename}"} 
                     alt="Current cover image"
                     class="max-w-xs h-auto rounded border" />
              </div>
            <% end %>
            
            <div phx-drop-target={@uploads.cover_image.ref} class="flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-lg hover:border-gray-400 transition-colors">
              <div class="space-y-1 text-center">
                <svg class="mx-auto h-12 w-12 text-gray-400" stroke="currentColor" fill="none" viewBox="0 0 48 48" aria-hidden="true">
                  <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
                </svg>
                <div class="flex text-sm text-gray-600">
                  <label class="relative cursor-pointer bg-white rounded-md font-medium text-indigo-600 hover:text-indigo-500 focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-indigo-500">
                    <span><%= if @post.cover_image_blob && @live_action == :edit, do: "Replace image", else: "Upload a file" %></span>
                    <.live_file_input upload={@uploads.cover_image} class="sr-only" />
                  </label>
                  <p class="pl-1">or drag and drop</p>
                </div>
                <p class="text-xs text-gray-500">PNG, JPG, GIF up to 10MB</p>
              </div>
            </div>
            
            <%= for entry <- @uploads.cover_image.entries do %>
              <div class="mt-3 p-3 bg-blue-50 rounded-lg border border-blue-200">
                <div class="flex items-start gap-3">
                  <div class="flex-shrink-0">
                    <.live_img_preview entry={entry} class="w-16 h-16 object-cover rounded border" />
                  </div>
                  <div class="flex-1">
                    <div class="flex items-center justify-between mb-2">
                      <span class="text-sm font-medium text-gray-900"><%= entry.client_name %></span>
                      <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref} class="text-red-600 hover:text-red-700 text-sm font-medium">Remove</button>
                    </div>
                    <div class="w-full bg-gray-200 rounded-full h-2">
                      <div class="bg-blue-600 h-2 rounded-full transition-all duration-300" style={"width: #{entry.progress}%"}></div>
                    </div>
                    <p class="text-xs text-gray-600 mt-1"><%= entry.progress %>% uploaded</p>
                  </div>
                </div>
              </div>
            <% end %>
            
            <%= for error <- upload_errors(@uploads.cover_image) do %>
              <div class="mt-2 p-2 bg-red-50 border border-red-200 rounded">
                <p class="text-sm text-red-600"><%= error_to_string(error) %></p>
              </div>
            <% end %>
          </div>
        </div>

        <footer class="mt-8 flex gap-3">
          <.button phx-disable-with="Saving..." variant="primary" class="flex-1 sm:flex-none">Save Post</.button>
          <.button navigate={return_path(@return_to, @post)} variant="secondary" class="flex-1 sm:flex-none">Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:uploaded_files, [])
     |> allow_upload(:cover_image, 
         accept: ~w(.jpg .jpeg .png .gif), 
         max_entries: 1,
         auto_upload: true)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    post = Blog.get_post!(id)

    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, post)
    |> assign(:form, to_form(Blog.change_post(post)))
  end

  defp apply_action(socket, :new, _params) do
    post = %Post{}

    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, post)
    |> assign(:form, to_form(Blog.change_post(post)))
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset = Blog.change_post(socket.assigns.post, post_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :cover_image, ref)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    post = socket.assigns.post
    action = socket.assigns.live_action
    
    case save_post(post, post_params, action) do
      {:ok, saved_post} ->
        saved_post = Repo.preload(saved_post, [:cover_image_ledger, :cover_image_blob])
        uploaded_files = consume_uploaded_entries(socket, :cover_image, EctoStorage.live_attach(saved_post, :cover_image))
        
        action_text = if action == :edit, do: "updated", else: "created"
        message = case uploaded_files do
          [%EctoStorage.Attachments.Attachment{blob_id: blob_id}] -> "Post #{action_text} successfully with image #{blob_id}"
          [] -> "Post #{action_text} successfully"
          other -> 
            require Logger
            Logger.warn("ImageUpload::Unexpected result: #{inspect(other)}")
            "Post #{action_text} but image upload failed"
        end
        
        {:noreply,
         socket
         |> put_flash(:info, message)
         |> push_navigate(to: return_path(socket.assigns.return_to, saved_post))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_post(_post, post_params, :new) do
    Blog.create_post(post_params)
  end

  defp save_post(post, post_params, :edit) do
    Blog.update_post(post, post_params)
  end

  defp error_to_string(:too_large), do: "File is too large"
  defp error_to_string(:not_accepted), do: "File type not accepted"
  defp error_to_string(:too_many_files), do: "Too many files"
  defp error_to_string(error), do: "Upload error: #{error}"

  defp return_path("index", _post), do: ~p"/posts"
  defp return_path("show", post), do: ~p"/posts/#{post}"
end
