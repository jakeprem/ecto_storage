defmodule BasicWeb.PostLive.Show do
  use BasicWeb, :live_view

  alias Basic.Blog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Post {@post.id}
        <:subtitle>This is a post record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/posts"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/posts/#{@post}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit post
          </.button>
        </:actions>
      </.header>

      <div class="space-y-6">
        <%= if @post.cover_image_blob do %>
          <div class="mb-6">
            <img src={~p"/blobs/proxy/#{@post.cover_image_blob.id}/#{@post.cover_image_blob.filename}"} 
                 alt="Cover image for #{@post.title}"
                 class="max-w-full h-auto rounded-lg shadow-lg" />
          </div>
        <% end %>

        <.list>
          <:item title="Title">{@post.title}</:item>
          <:item title="Body">
            <div class="whitespace-pre-wrap">{@post.body}</div>
          </:item>
        </.list>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Post")
     |> assign(:post, Blog.get_post!(id))}
  end
end
