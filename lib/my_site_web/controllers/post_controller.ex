defmodule MySiteWeb.PostController do
  use MySiteWeb, :controller
  alias MySite.{Post,Repo}

  plug :check_user_is_authorized

  def index(conn, _params) do
    posts = Repo.all(Post)
    render(conn, "index.html", posts: posts)
  end
end
