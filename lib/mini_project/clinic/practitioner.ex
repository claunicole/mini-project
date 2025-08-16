defmodule MiniProject.Clinic.Practitioner do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:first_name, :last_name],
    sortable: [:first_name, :last_name, :inserted_at],
    default_limit: 10,
    default_order: %{order_by: [:last_name, :first_name], order_directions: [:asc, :asc]}
  }

  schema "practitioners" do
    field :first_name, :string
    field :last_name, :string
    field :phone, :string
    field :birthdate, :date
    field :email, :string

    timestamps(type: :utc_datetime)
  end

  @required [:first_name, :last_name, :phone, :birthdate, :email]
  @email_rx ~r/^[^\s]+@[^\s]+$/i

  @doc false
  def changeset(practitioner, attrs) do
    practitioner
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> update_change(:email, &String.trim/1)
    |> validate_format(:email, @email_rx)
    |> unique_constraint(:email)
  end
end
