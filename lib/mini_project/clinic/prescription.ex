defmodule MiniProject.Clinic.Prescription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prescriptions" do
    field :detail, :string
    belongs_to :patient, MiniProject.Clinic.Patient
    belongs_to :practitioner, MiniProject.Clinic.Practitioner

    timestamps(type: :utc_datetime)
  end

  @required [:detail, :practitioner_id, :patient_id]

  @doc false
  def changeset(prescription, attrs) do
    prescription
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> validate_length(:detail, min: 5, max: 500)
    |> assoc_constraint(:patient)     
    |> assoc_constraint(:practitioner)  
  end
end
