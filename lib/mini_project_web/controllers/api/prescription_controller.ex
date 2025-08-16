defmodule MiniProjectWeb.Api.PrescriptionController do
  use MiniProjectWeb, :controller

  alias MiniProject.Clinic
  alias MiniProject.Clinic.Prescription

  action_fallback MiniProjectWeb.FallbackController

  def index(conn, _params) do
    prescriptions = Clinic.list_prescriptions()
    render(conn, :index, prescriptions: prescriptions)
  end

  def create(conn, %{"prescription" => prescription_params}) do
    with {:ok, %Prescription{} = prescription} <- Clinic.create_prescription(prescription_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/prescriptions/#{prescription}")
      |> render(:show, prescription: prescription)
    end
  end

  def show(conn, %{"id" => id}) do
    prescription = Clinic.get_prescription!(id)
    render(conn, :show, prescription: prescription)
  end

  def update(conn, %{"id" => id, "prescription" => prescription_params}) do
    prescription = Clinic.get_prescription!(id)

    with {:ok, %Prescription{} = prescription} <- Clinic.update_prescription(prescription, prescription_params) do
      render(conn, :show, prescription: prescription)
    end
  end

  def delete(conn, %{"id" => id}) do
    prescription = Clinic.get_prescription!(id)

    with {:ok, %Prescription{}} <- Clinic.delete_prescription(prescription) do
      send_resp(conn, :no_content, "")
    end
  end
end
