defmodule MySite.Posts do
  @moduledoc """
  Module that allows you to perform basic operations on Post model
  """

  alias MySite.{
    Post,
    Repo
  }

  @spec create(map) :: {:ok, Post.t()} | {:error, Ecto.Changeset.t()}
  def create(%{} = attrs) do
    Post.changeset(%Post{}, attrs)
    |> Repo.insert()
  end

  @spec update(Post.t(), map) :: {:ok, Post.t()} | {:error, Ecto.Changeset.t()}
  def update(%Post{id: id} = post, %{} = attrs) when id != nil do
    Post.changeset(post, attrs)
    |> Repo.update()
  end

  @spec get(integer) :: Post.t() | nil
  def get(id) when id != nil do
    Repo.get(Post, id)
  end

  @spec delete(Post.t()) :: {:ok, Post.t()} | {:error, Ecto.Changeset.t()}
  def delete(%Post{id: id} = post) when not is_nil(id) do
    Repo.delete(post)
  end
end
