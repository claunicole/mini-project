defmodule MiniProjectWeb.Api.PatientController do
  use MiniProjectWeb, :controller

  alias MiniProject.Clinic
  alias MiniProject.Clinic.Patient

  action_fallback MiniProjectWeb.FallbackController

  def index(conn, _params) do
    patients = Clinic.list_patients()
    json(conn, %{data: Enum.map(patients, &patient_json/1)})
  end

  def create(conn, %{"patient" => attrs}) do
    with {:ok, %Patient{} = patient} <- Clinic.create_patient(attrs) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/patients/#{patient}")
      |> json(%{data: patient_json(patient)})
    end
  end

  def show(conn, %{"id" => id}) do
    patient = Clinic.get_patient!(id)
    json(conn, %{data: patient_json(patient)})
  end

  def update(conn, %{"id" => id, "patient" => attrs}) do
    patient = Clinic.get_patient!(id)

    with {:ok, %Patient{} = patient} <- Clinic.update_patient(patient, attrs) do
      json(conn, %{data: patient_json(patient)})
    end
  end

  def delete(conn, %{"id" => id}) do
    patient = Clinic.get_patient!(id)

    with {:ok, %Patient{}} <- Clinic.delete_patient(patient) do
      send_resp(conn, :no_content, "")
    end
  end

  # ---- Helpers ----
  defp patient_json(p) do
    %{
      id: p.id,
      first_name: p.first_name,
      last_name: p.last_name,
      email: p.email,
      phone: p.phone,
      birthdate: p.birthdate
    }
  end
end