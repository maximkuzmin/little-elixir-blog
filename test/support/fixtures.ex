defmodule MySite.Support.Fixtures do
  @moduledoc false
  alias MySite.{
    Post,
    Posts,
    Repo,
    User
  }

  @valid_post_params %{
    markdown: "Valid post markdown",
    header: "Valid post header"
  }

  @valid_user_params %{
    name: "Test User",
    email: "user@test.com",
    password: "SupersecurePassword12",
    password_confirmation: "SupersecurePassword12"
  }

  @spec post_fixture(map) :: {:error, Ecto.Changeset.t()} | {:ok, Post.t()}
  def post_fixture(attrs) when is_map(attrs) do
    Posts.create(attrs)
  end

  @spec post_fixture :: {:error, Ecto.Changeset.t()} | {:ok, Post.t()}
  def post_fixture do
    post_fixture(@valid_post_params)
  end

  @spec user_fixture :: {:error, Ecto.Changeset.t()} | {:ok, User.t()}
  def user_fixture do
    User.creation_changeset(%User{}, @valid_user_params)
    |> Repo.insert()
  end
end
