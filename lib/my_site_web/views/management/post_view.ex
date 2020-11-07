defmodule MySiteWeb.Management.PostView do
  use MySiteWeb, :view
  alias MySite.Post
  import Phoenix.HTML, only: [raw: 1]

  def as_html(%Post{} = post) do
    post
    |> Post.as_html()
    |> raw()
  end
end
