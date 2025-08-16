defmodule MiniProject.ClinicFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MiniProject.Clinic` context.
  """

  alias MiniProject.Clinic
  
  defp unique_int, do: System.unique_integer([:positive])
  defp unique_email, do: "user#{System.unique_integer()}@example.com"

  @doc """
  Generate a patient.
  """
  def patient_fixture(attrs \\ %{}) do
    {:ok, patient} =
      attrs
      |> Enum.into(%{
        first_name: "John",
        last_name: "Doe",
        phone: "555-1234",
        birthdate: ~D[1990-01-01],
        email: unique_email()
      })
      |> MiniProject.Clinic.create_patient()

    patient
  end

  @doc """
  Generate a practitioner.
  """
  def practitioner_fixture(attrs \\ %{}) do
    {:ok, practitioner} =
      attrs
      |> Enum.into(%{
        first_name: "Jane",
        last_name: "Smith",
        phone: "555-5678",
        birthdate: ~D[1985-02-02],
        email: unique_email()
      })
      |> MiniProject.Clinic.create_practitioner()

    practitioner
  end

  @doc """
  Generate a prescription.
  """
 def prescription_fixture(attrs \\ %{}) do
    patient = Map.get_lazy(attrs, :patient, &patient_fixture/0)
    doctor  = Map.get_lazy(attrs, :practitioner, &practitioner_fixture/0)

    base = %{
      detail: "some detail",
      patient_id: patient.id,
      practitioner_id: doctor.id
    }

    {:ok, rx} = Clinic.create_prescription(Map.merge(base, Map.drop(attrs, [:patient, :practitioner])))
    rx
  end
end
