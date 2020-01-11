defmodule MySiteWeb.SessionController do
  use MySiteWeb, :controller
  alias MySiteWeb.Services.Authentication, as: Auth

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{email: email, password: password}) do
    result = Auth.login_with_email_and_password(conn, email, password, repo: MySite.Repo)

    case result do
      {:ok, conn} ->
        redirect(conn, to: Routes.page_path(conn, :index))

      {:error, :unauthorized, conn} ->
        conn
        |> put_flash(:error, "Wrong something, try again!")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Auth.logout!()
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
