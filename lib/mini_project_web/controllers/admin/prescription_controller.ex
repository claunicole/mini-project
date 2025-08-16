defmodule MiniProjectWeb.Admin.PrescriptionController do
  use MiniProjectWeb, :controller

  alias MiniProject.Clinic
  alias MiniProject.Clinic.Prescription

  def index(conn, params) do
    {:ok, {prescriptions, meta}} = MiniProject.Clinic.paginate_prescriptions(params)
    render(conn, :index, prescriptions: prescriptions, meta: meta, q: Map.get(params, "q", ""))
  end

  def new(conn, _params) do
    changeset = Clinic.change_prescription(%Prescription{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"prescription" => prescription_params}) do
    case Clinic.create_prescription(prescription_params) do
      {:ok, prescription} ->
        conn
        |> put_flash(:info, "Prescription created successfully.")
        |> redirect(to: ~p"/admin/prescriptions/#{prescription}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    prescription = MiniProject.Clinic.get_prescription!(id) |> MiniProject.Repo.preload([:patient, :practitioner])
    render(conn, :show, prescription: prescription)
  end

  def edit(conn, %{"id" => id}) do
    prescription = Clinic.get_prescription!(id)
    changeset = Clinic.change_prescription(prescription)
    render(conn, :edit, prescription: prescription, changeset: changeset)
  end

  def update(conn, %{"id" => id, "prescription" => prescription_params}) do
    prescription = Clinic.get_prescription!(id)

    case Clinic.update_prescription(prescription, prescription_params) do
      {:ok, prescription} ->
        conn
        |> put_flash(:info, "Prescription updated successfully.")
        |> redirect(to: ~p"/admin/prescriptions/#{prescription}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, prescription: prescription, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    prescription = Clinic.get_prescription!(id)
    {:ok, _prescription} = Clinic.delete_prescription(prescription)

    conn
    |> put_flash(:info, "Prescription deleted successfully.")
    |> redirect(to: ~p"/admin/prescriptions")
  end
end
