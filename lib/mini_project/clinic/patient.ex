defmodule MiniProject.Clinic.Patient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "patients" do
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
  def changeset(patient, attrs) do
    patient
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> update_change(:email, &String.trim/1)
    |> validate_format(:email, @email_rx)
    |> unique_constraint(:email)
  end
end
