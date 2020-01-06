defmodule MySite.Models.UserTest do
  use ExUnit.Case, async: true
  alias MySite.User
  @valid_user %{
    name: "Test User",
    email: "user@test.com",
    password: "SupersecurePassword12",
    password_confirmation: "SupersecurePassword12"
  }

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(MySite.Repo)
  end

  test "#creation_changeset tests password and password_confirmation similarity" do
    invalid_user = @valid_user |> Map.put(:password_confirmation, "Not so secure password")
    result = User.creation_changeset(%User{},invalid_user)
    assert(result.valid? == false)
    assert(Keyword.get(result.errors, :password_confirmation) != nil)
  end

  test "#creation_changeset checks if password at least 8 symbols long" do
    invalid_user =
      @valid_user |> Map.merge(%{password: "123456A", password_confirmation: "123456A"})
    result = User.creation_changeset(%User{},invalid_user)
    assert(result.valid? == false)
    assert(Keyword.get(result.errors, :password) != nil)
  end

  test "#creation_changeset hashes password" do
    result = User.creation_changeset(%User{}, @valid_user)
    assert(Ecto.Changeset.get_change(result, :password) == nil)
    assert(Ecto.Changeset.get_change(result, :password_hash) != @valid_user.password)
    assert(Ecto.Changeset.get_change(result, :password_hash) |> is_binary)
  end

  test "it inserts new record after creation_changeset" do
    user = User.creation_changeset(%User{}, @valid_user) |> MySite.Repo.insert!
    assert(user.id != nil)
    assert(user.updated_at != nil)
  end
end