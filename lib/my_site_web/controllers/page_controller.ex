defmodule MySiteWeb.PageController do
  use MySiteWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
