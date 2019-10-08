defmodule MySiteWeb.PageController do
  use MySiteWeb, :controller
  alias MySite.Repo
  alias MySite.Post
  import Ecto.Query, only: [from: 2]

  def index(conn, _params) do
    blog_posts = Repo.all(from p in Post, [order_by: :inserted_at])
    render(conn, "index.html", blog_posts: blog_posts)
  end
end
