defmodule BasicWeb.PostLive.Index do
  use BasicWeb, :live_view

  alias Basic.Blog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Posts
        <:actions>
          <.button variant="primary" navigate={~p"/posts/new"}>
            <.icon name="hero-plus" /> New Post
          </.button>
        </:actions>
      </.header>

      <.table
        id="posts"
        rows={@streams.posts}
        row_click={fn {_id, post} -> JS.navigate(~p"/posts/#{post}") end}
      >
        <:col :let={{_id, post}} label="Cover Image">
          <%= if post.cover_image_blob do %>
            <img src={~p"/blobs/redirect/#{post.cover_image_blob.id}/#{post.cover_image_blob.filename}"} 
                 alt="Cover image for #{post.title}"
                 class="w-16 h-16 object-cover rounded" />
          <% else %>
            <div class="w-16 h-16 bg-gray-200 rounded flex items-center justify-center">
              <.icon name="hero-photo" class="w-8 h-8 text-gray-400" />
            </div>
          <% end %>
        </:col>
        <:col :let={{_id, post}} label="Title">{post.title}</:col>
        <:col :let={{_id, post}} label="Body">{String.slice(post.body, 0, 100)}</:col>
        <:action :let={{_id, post}}>
          <div class="sr-only">
            <.link navigate={~p"/posts/#{post}"}>Show</.link>
          </div>
          <.link navigate={~p"/posts/#{post}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, post}}>
          <.link
            phx-click={JS.push("delete", value: %{id: post.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Posts")
     |> stream(:posts, list_posts())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Blog.get_post!(id)
    {:ok, _} = Blog.delete_post(post)

    {:noreply, stream_delete(socket, :posts, post)}
  end

  defp list_posts() do
    Blog.list_posts()
  end
end
