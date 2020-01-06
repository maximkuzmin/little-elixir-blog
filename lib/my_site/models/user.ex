defmodule MySite.User do
  @moduledoc """
  Ecto model to work with app users
  """
  use Ecto.Schema
  import Ecto.Changeset

  @email_regexp ~r/([A-z]|\.|\d)+\@([A-z]|\d)+\.[A-z]{2,}/
  @username_regexp ~r/[A-z0-9]+/

  schema "users" do
    field :email, :string
    field :name, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name])
    |> validate_required([:email, :name])
    |> unique_constraint(:email)
    |> unique_constraint(:name)
  end

  def creation_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_password_confirmation()
    |> validate_length(:password, min: 8)
    |> hash_password()
  end

  defp validate_password_confirmation(
         %{
           valid?: true,
           changes: %{password: password, password_confirmation: password_confirmation}
         } = changeset
       ) when password == password_confirmation,  do: changeset
  defp validate_password_confirmation(%{valid?: true} = changeset) do
    add_error(changeset, :password_confirmation, "Password and confirmation must be equal")
  end
  defp validate_password_confirmation(changeset), do: changeset

  defp hash_password(%{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Bcrypt.add_hash(password))
    |> delete_change(:password)
  end
  defp hash_password(changeset), do: changeset
end
