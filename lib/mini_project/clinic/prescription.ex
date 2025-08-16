defmodule MiniProject.Clinic.Prescription do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [
      :detail,
      :patient_first_name, :patient_last_name,
      :practitioner_first_name, :practitioner_last_name,
      :patient_name, :practitioner_name
    ],
    sortable: [
      :id, :inserted_at,
      :patient_last_name, :patient_first_name,
      :practitioner_last_name, :practitioner_first_name,
      :patient_name, :practitioner_name
    ],
    default_limit: 10,
    default_order: %{order_by: [:inserted_at], order_directions: [:desc]},
    adapter_opts: [
      join_fields: [
        patient_first_name:      [binding: :patient,      field: :first_name,      ecto_type: :string],
        patient_last_name:       [binding: :patient,      field: :last_name,       ecto_type: :string],
        practitioner_first_name: [binding: :practitioner, field: :first_name,      ecto_type: :string],
        practitioner_last_name:  [binding: :practitioner, field: :last_name,       ecto_type: :string]
      ],
      compound_fields: [
        patient_name:      [:patient_last_name, :patient_first_name],
        practitioner_name: [:practitioner_last_name, :practitioner_first_name]
      ]
    ]
  }

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
