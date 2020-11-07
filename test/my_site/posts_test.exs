defmodule MySite.PostsTest do
  alias MySite.Post
  alias MySite.Posts, as: Described
  use MySite.DataCase

  @valid_post_params %{
    header: "Test header",
    markdown: "This is a markdown"
  }
  @new_header "New header"
  @no_header_post_params Map.delete(@valid_post_params, :header)
  @no_markdown_post_params Map.delete(@valid_post_params, :markdown)

  describe "create/1" do
    test "creates a post and returns {:ok, Post.t()} if attrs are okay" do
      before_count = Repo.aggregate(Post, :count, :id)
      res = Described.create(@valid_post_params)
      after_count = Repo.aggregate(Post, :count, :id)
      assert(before_count + 1 == after_count)
      assert({:ok, %Post{id: id}} = res)
      id |> is_nil() |> refute()
    end

    test "creates no records and returns {:error, Ecto.Changeset.t()} if provided params are bad" do
      before_count = Repo.aggregate(Post, :count, :id)
      {:error, %Ecto.Changeset{}} = Described.create(@no_header_post_params)
      {:error, %Ecto.Changeset{}} = Described.create(@no_markdown_post_params)
      after_count = Repo.aggregate(Post, :count, :id)
      assert(before_count == after_count)
    end
  end

  describe "#get/1" do
    setup do
      {:ok, post} = Described.create(@valid_post_params)
      {:ok, post: post}
    end

    test "gets record if exists", %{post: post} do
      assert(post == Described.get(post.id))
    end

    test "returns nil if not exist" do
      assert(nil == Described.get(-1))
    end
  end

  describe "#update/2" do
    setup do
      {:ok, post} = Described.create(@valid_post_params)
      {:ok, post: post}
    end

    test "updates post and returns {:ok, post}", %{post: post} do
      {:ok, %Post{} = updated_post} = Described.update(post, %{header: @new_header})
      assert(updated_post.header == @new_header)
      assert(Described.get(post.id) == updated_post)
    end

    test "returns {:error, Ecto.Changeset.t()} if something went wrong", %{post: post} do
      assert({:error, %Ecto.Changeset{}} = Described.update(post, %{header: nil}))
    end
  end

  describe "#delete/1" do
    setup do
      {:ok, post} = Described.create(@valid_post_params)
      {:ok, post: post}
    end

    test "deletes post from the db", %{post: post} do
      before_count = Repo.aggregate(Post, :count, :id)
      {:ok, %Post{} = deleted_post} = Described.delete(post)
      assert(post.id == deleted_post.id)
      after_count = Repo.aggregate(Post, :count, :id)
      assert(after_count + 1 == before_count)
    end
  end
end
