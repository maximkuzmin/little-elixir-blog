defmodule MySite.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :markdown, :text
      add :header, :text

      timestamps()
    end

  end
end
