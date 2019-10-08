defmodule MySite.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :header, :string
    field :markdown, :string

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
      |> cast(attrs, [:markdown, :header])
      |> validate_required([:markdown, :header])
  end

  def as_html(%MySite.Post{markdown: markdown}) do
    result = Earmark.as_html(markdown)

    case result do
      {:ok, html, _} -> html
      {:error, _, _} -> ""
    end
  end
end
