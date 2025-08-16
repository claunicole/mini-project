defmodule MiniProjectWeb.Admin.PatientController do
  use MiniProjectWeb, :controller

  alias MiniProject.Clinic
  alias MiniProject.Clinic.Patient

  def index(conn, params) do
   case MiniProject.Clinic.paginate_patients(params) do
      {:ok, {patients, meta}} ->
        render(conn, :index, patients: patients, meta: meta, q: Map.get(params, "q", ""))

      {:error, flop_changeset} ->
        render(conn, :index, patients: [], meta: Flop.Meta.new(), flop_changeset: flop_changeset, q: Map.get(params, "q", ""))
    end
  end

  def new(conn, _params) do
    changeset = Clinic.change_patient(%Patient{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"patient" => patient_params}) do
    case Clinic.create_patient(patient_params) do
      {:ok, patient} ->
        conn
        |> put_flash(:info, "Patient created successfully.")
        |> redirect(to: ~p"/admin/patients/#{patient}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    patient = Clinic.get_patient!(id)
    render(conn, :show, patient: patient)
  end

  def edit(conn, %{"id" => id}) do
    patient = Clinic.get_patient!(id)
    changeset = Clinic.change_patient(patient)
    render(conn, :edit, patient: patient, changeset: changeset)
  end

  def update(conn, %{"id" => id, "patient" => patient_params}) do
    patient = Clinic.get_patient!(id)

    case Clinic.update_patient(patient, patient_params) do
      {:ok, patient} ->
        conn
        |> put_flash(:info, "Patient updated successfully.")
        |> redirect(to: ~p"/admin/patients/#{patient}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, patient: patient, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    patient = Clinic.get_patient!(id)
    case MiniProject.Clinic.delete_patient(patient) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Paciente eliminado correctamente.")
        |> redirect(to: ~p"/admin/patients")

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:error, "No se puede eliminar: el paciente tiene recetas asociadas.")
        |> redirect(to: ~p"/admin/patients/#{patient}")
    end
  end
end
