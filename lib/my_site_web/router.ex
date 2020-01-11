defmodule MySiteWeb.Router do
  use MySiteWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug MySiteWeb.Services.Authentication, repo: MySite.Repo
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MySiteWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/session", SessionController, only: [:new, :create, :delete]
    resources "/posts", PostController, only: [:index]
  end

  # Other scopes may use custom stacks.
  # scope "/api", MySiteWeb do
  #   pipe_through :api
  # end
end
