defmodule MySiteWeb.Management.PostControllerTest do
  use MySiteWeb.ConnCase

  alias MySite.{
    Post,
    Posts,
    Repo
  }

  # alias MySiteWeb.Services.Authentication, as: Auth

  setup do
    {:ok, post} = post_fixture()
    {:ok, user} = user_fixture()
    {:ok, post: post, user: user}
  end

  describe "delete" do
    test "deletes a post", %{conn: conn, post: post, user: user} do
      before_count = Repo.aggregate(Post, :count, :id)

      %{status: status} =
        conn
        |> init_test_session(%{user_id: user.id})
        |> delete(Routes.post_path(conn, :delete, post.id), %{})

      assert(status == 302)
      after_count = Repo.aggregate(Post, :count, :id)
      assert(after_count + 1 == before_count)
    end

    test "returns 404 when post is not found", %{conn: conn, user: user} do
      before_count = Repo.aggregate(Post, :count, :id)

      %{status: status} =
        conn
        |> init_test_session(%{user_id: user.id})
        |> delete(Routes.post_path(conn, :delete, "-1"), %{})

      assert(status == 404)
      after_count = Repo.aggregate(Post, :count, :id)
      assert(after_count == before_count)
    end

    test "redirects if user not logged in", %{conn: conn, post: post} do
      before_count = Repo.aggregate(Post, :count, :id)

      %{status: status} =
        conn
        |> delete(Routes.post_path(conn, :delete, post.id), %{})

      assert(status == 302)
      after_count = Repo.aggregate(Post, :count, :id)
      assert(after_count == before_count)
    end
  end

  describe "/edit" do
    test "renders 200 if all is ok", %{conn: conn, post: post, user: user} do
      %{status: status} =
        conn
        |> init_test_session(%{user_id: user.id})
        |> get(Routes.post_path(conn, :edit, post.id))

      assert(status == 200)
    end

    test "renders 302 if no user", %{conn: conn, post: post} do
      %{status: status} =
        conn
        |> get(Routes.post_path(conn, :edit, post.id))

      assert(status == 302)
    end

    test "renders 404 if no post", %{conn: conn, user: user} do
      %{status: status} =
        conn
        |> init_test_session(%{user_id: user.id})
        |> get(Routes.post_path(conn, :edit, -1))

      assert(status == 404)
    end
  end

  describe "/update" do
    @new_header_value "New header value"
    test "updates record if all is ok", %{conn: conn, post: post, user: user} do
      %{status: status} =
        conn
        |> init_test_session(%{user_id: user.id})
        |> patch(Routes.post_path(conn, :update, post.id), %{post: %{header: @new_header_value}})

      assert(status == 302)
      post = Posts.get(post.id)
      assert(post.header == @new_header_value)
    end

    test "does not update record if params aren't good", %{conn: conn, post: post, user: user} do
      %{status: status} =
        conn
        |> init_test_session(%{user_id: user.id})
        |> patch(Routes.post_path(conn, :update, post.id), %{post: %{header: nil}})

      assert(status == 200)
      post = Posts.get(post.id)
      assert(post.header != nil)
    end

    test "doesn't update record if the user is not logged in", %{conn: conn, post: post} do
      %{status: status} =
        conn
        |> patch(Routes.post_path(conn, :update, post.id), %{post: %{header: @new_header_value}})

      assert(status == 302)
      post = Posts.get(post.id)
      assert(post.header != @new_header_value)
    end

    test "doesn't update record if the post id is wrong", %{conn: conn, post: post, user: user} do
      %{status: status} =
        conn
        |> init_test_session(%{user_id: user.id})
        |> patch(Routes.post_path(conn, :update, "-1"), %{post: %{header: @new_header_value}})

      assert(status == 404)
      post = Posts.get(post.id)
      assert(post.header != @new_header_value)
    end
  end

  describe "/new" do
    test "renders 200 if user is logged in", %{conn: conn, user: user} do
      %{status: status} =
        conn
        |> init_test_session(%{user_id: user.id})
        |> get(Routes.post_path(conn, :new))

      assert(status == 200)
    end

    test "renders something else if user not logged in", %{conn: conn} do
      %{status: status} =
        conn
        |> get(Routes.post_path(conn, :new))

      refute(status == 200)
    end
  end

  describe "#create" do
    test "redirect to index if everything is okay", %{conn: conn, user: user, post: post} do
      before_count = Repo.aggregate(Post, :count, :id)

      {_, post_params} =
        post
        |> Map.from_struct()
        |> Enum.map(fn {k_atom, v} -> {Atom.to_string(k_atom), v} end)
        |> Enum.into(%{})
        |> Map.split(["__meta__", "updated_at", "inserted_at", "id"])

      %{status: status} =
        conn
        |> init_test_session(%{user_id: user.id})
        |> post(Routes.post_path(conn, :create, post: post_params))

      assert(status == 302)
      after_count = Repo.aggregate(Post, :count, :id)
      assert(before_count + 1 == after_count)
    end

    test "render form again if params are not enough", %{conn: conn, user: user} do
      before_count = Repo.aggregate(Post, :count, :id)

      post_params = %{header: "The header"}

      %{status: status} =
        conn
        |> init_test_session(%{user_id: user.id})
        |> post(Routes.post_path(conn, :create, post: post_params))

      assert(status == 200)
      after_count = Repo.aggregate(Post, :count, :id)
      assert(before_count == after_count)
    end

    test "renders something else if user not logged in", %{conn: conn} do
      %{status: status} =
        conn
        |> post(Routes.post_path(conn, :create))

      refute(status == 200)
    end
  end
end
