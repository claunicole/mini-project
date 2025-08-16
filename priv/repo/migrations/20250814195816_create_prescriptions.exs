defmodule MiniProject.Repo.Migrations.CreatePrescriptions do
  use Ecto.Migration

  def change do
    create table(:prescriptions) do
      add :detail, :text, null: false
      add :practitioner_id, references(:practitioners, on_delete: :nothing), null: false
      add :patient_id, references(:patients, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:prescriptions, [:practitioner_id])
    create index(:prescriptions, [:patient_id])
    create index(:prescriptions, [:patient_id, :practitioner_id])
  end
end
