defmodule MySiteWeb.Management.PostController do
  use MySiteWeb, :controller

  alias MySite.{
    Post,
    Posts,
    Repo
  }

  plug :set_post when action in [:update, :edit, :show, :delete]

  def new(conn, _params) do
    post = Post.new_changeset()
    render(conn, "new.html", post: post)
  end

  def create(conn, %{"post" => post_params}) when is_map(post_params) do
    Post.new_changeset()
    |> Post.changeset(post_params)
    |> Repo.insert()
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:success, "New post added")
        |> redirect(to: Routes.post_path(conn, :index))

      {:error, %Ecto.Changeset{} = error_changeset} ->
        conn
        |> put_flash(:error, "Post wasn't created")
        |> render("new.html", post: error_changeset)
    end
  end

  def index(conn, _params) do
    posts = Repo.all(Post)
    render(conn, "index.html", posts: posts)
  end

  def edit(conn, %{"id" => id}) do
    post = Repo.get!(Post, id) |> Post.changeset(%{})
    render(conn, "edit.html", post: post)
  end

  def update(conn, %{"post" => post_params} = _params) do
    case Posts.update(conn.assigns.post, post_params) do
      {:ok, %Post{}} ->
        conn
        |> put_flash(:success, "Post was updated successfully")
        |> redirect(to: Routes.post_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Post wasn't updated, Please, check the errors")
        |> render("edit.html", post: changeset)
    end
  end

  def delete(%{assigns: %{post: %Post{} = post}} = conn, _params) do
    Posts.delete(post)
    |> case do
      {:ok, _} ->
        conn
        |> put_flash(:success, "Post deleted")
        |> redirect(to: Routes.post_path(conn, :index))

      {:error, _} ->
        conn
        |> put_flash(:error, "Post wasn't deleted")
        |> redirect(to: Routes.post_path(conn, :index))
    end
  end

  def set_post(conn, _opts) do
    conn.params
    |> Map.get("id", nil)
    |> Posts.get()
    |> case do
      %Post{} = post ->
        Plug.Conn.assign(conn, :post, post)

      nil ->
        Plug.Conn.put_status(conn, 404)
        |> text("There is no such post")
        |> halt()
    end
  end
end
