defmodule MiniProject.Clinic.Patient do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:first_name, :last_name],
    sortable: [:first_name, :last_name, :inserted_at],
    default_limit: 10,
    default_order: %{order_by: [:last_name, :first_name], order_directions: [:asc, :asc]}
  }

  schema "patients" do
    field :first_name, :string
    field :last_name, :string
    field :phone, :string
    field :birthdate, :date
    field :email, :string

    has_many :prescriptions, MiniProject.Clinic.Prescription, foreign_key: :patient_id

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

  def delete_changeset(%__MODULE__{} = patient) do
    Ecto.Changeset.change(patient)
    |> Ecto.Changeset.no_assoc_constraint(:prescriptions,
         message: "no puede eliminarse porque tiene recetas asociadas")
  end
end
