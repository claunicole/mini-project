defmodule MiniProjectWeb.Api.PractitionerController do
  use MiniProjectWeb, :controller

  alias MiniProject.Clinic
  alias MiniProject.Clinic.Practitioner

  action_fallback MiniProjectWeb.FallbackController

  def index(conn, _params) do
    practitioners = Clinic.list_practitioners()
    render(conn, :index, practitioners: practitioners)
  end

  def create(conn, %{"practitioner" => practitioner_params}) do
    with {:ok, %Practitioner{} = practitioner} <- Clinic.create_practitioner(practitioner_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/api/practitioners/#{practitioner}")
      |> render(:show, practitioner: practitioner)
    end
  end

  def show(conn, %{"id" => id}) do
    practitioner = Clinic.get_practitioner!(id)
    render(conn, :show, practitioner: practitioner)
  end

  def update(conn, %{"id" => id, "practitioner" => practitioner_params}) do
    practitioner = Clinic.get_practitioner!(id)

    with {:ok, %Practitioner{} = practitioner} <- Clinic.update_practitioner(practitioner, practitioner_params) do
      render(conn, :show, practitioner: practitioner)
    end
  end

  def delete(conn, %{"id" => id}) do
    practitioner = Clinic.get_practitioner!(id)

    with {:ok, %Practitioner{}} <- Clinic.delete_practitioner(practitioner) do
      send_resp(conn, :no_content, "")
    end
  end
end
