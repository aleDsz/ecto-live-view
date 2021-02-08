defmodule EctoLiveView.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @allowed_status ~w(pending approved blocked inactive)

  @fields ~w(name birth_date height is_admin status)a

  schema "users" do
    field :name, :string
    field :birth_date, :date
    field :height, :integer
    field :is_admin, :boolean
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_inclusion(:status, @allowed_status)
  end

  @doc false
  def allowed_status, do: @allowed_status
end
