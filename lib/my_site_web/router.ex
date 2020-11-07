defmodule MySiteWeb.Router do
  use MySiteWeb, :router
  alias MySiteWeb.Services.Authentication
  import Authentication, only: [check_user_is_authorized: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Authentication, repo: MySite.Repo
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :logged_as_manager do
    plug :check_user_is_authorized
  end

  scope "/", MySiteWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/session", SessionController, only: [:new, :create, :delete]
  end

  scope "/management/", MySiteWeb.Management do
    pipe_through [:browser, :logged_as_manager]
    resources "/posts", PostController, except: [:show]
  end
end
