defmodule EctoLiveView.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :birth_date, :date, null: false
      add :height, :integer, null: false
      add :is_admin, :boolean, null: false
      add :status, :string, null: false

      timestamps()
    end
  end
end
