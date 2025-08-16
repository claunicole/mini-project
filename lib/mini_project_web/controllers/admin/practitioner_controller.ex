defmodule MiniProjectWeb.Admin.PractitionerController do
  use MiniProjectWeb, :controller

  alias MiniProject.Clinic
  alias MiniProject.Clinic.Practitioner

  def index(conn, params) do
    case MiniProject.Clinic.paginate_practitioners(params) do
      {:ok, {practitioners, meta}} ->
        render(conn, :index, practitioners: practitioners, meta: meta, q: Map.get(params, "q", ""))

      {:error, flop_changeset} ->
        render(conn, :index, practitioners: [], meta: Flop.Meta.new(), flop_changeset: flop_changeset, q: Map.get(params, "q", ""))
    end
  end

  def new(conn, _params) do
    changeset = Clinic.change_practitioner(%Practitioner{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"practitioner" => practitioner_params}) do
    case Clinic.create_practitioner(practitioner_params) do
      {:ok, practitioner} ->
        conn
        |> put_flash(:info, "Practitioner created successfully.")
        |> redirect(to: ~p"/admin/practitioners/#{practitioner}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    practitioner = Clinic.get_practitioner!(id)
    render(conn, :show, practitioner: practitioner)
  end

  def edit(conn, %{"id" => id}) do
    practitioner = Clinic.get_practitioner!(id)
    changeset = Clinic.change_practitioner(practitioner)
    render(conn, :edit, practitioner: practitioner, changeset: changeset)
  end

  def update(conn, %{"id" => id, "practitioner" => practitioner_params}) do
    practitioner = Clinic.get_practitioner!(id)

    case Clinic.update_practitioner(practitioner, practitioner_params) do
      {:ok, practitioner} ->
        conn
        |> put_flash(:info, "Practitioner updated successfully.")
        |> redirect(to: ~p"/admin/practitioners/#{practitioner}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, practitioner: practitioner, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    practitioner = Clinic.get_practitioner!(id)
    {:ok, _practitioner} = Clinic.delete_practitioner(practitioner)

    conn
    |> put_flash(:info, "Practitioner deleted successfully.")
    |> redirect(to: ~p"/admin/practitioners")
  end
end
