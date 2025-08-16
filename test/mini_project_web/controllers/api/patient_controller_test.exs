defmodule MiniProjectWeb.Api.PatientControllerTest do
  use MiniProjectWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end 

  import MiniProject.ClinicFixtures

  alias MiniProject.Clinic.Patient

  @create_attrs %{
    first_name: "some first_name",
    last_name: "some last_name",
    phone: "some phone",
    birthdate: ~D[2025-08-15],
    email: "some_email@mail.com"
  }
  @update_attrs %{
    first_name: "some updated first_name",
    last_name: "some updated last_name",
    phone: "some updated phone",
    birthdate: ~D[2025-08-16],
    email: "some_email2@mail.com"
  }
  @invalid_attrs %{first_name: nil, last_name: nil, phone: nil, birthdate: nil, email: nil}

  describe "index" do
    test "lists all patients", %{conn: conn} do
      conn = get(conn, ~p"/api/patients")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create patient" do
    test "renders patient when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/patients", patient: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/patients/#{id}")

      assert %{
               "id" => ^id,
               "birthdate" => "2025-08-15",
               "email" => "some_email@mail.com",
               "first_name" => "some first_name",
               "last_name" => "some last_name",
               "phone" => "some phone"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/patients", patient: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update patient" do
    setup [:create_patient]

    test "renders patient when data is valid", %{conn: conn, patient: %Patient{id: id} = patient} do
      conn = put(conn, ~p"/api/patients/#{patient}", patient: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/patients/#{id}")

      assert %{
               "id" => ^id,
               "birthdate" => "2025-08-16",
               "email" => "some_email2@mail.com",
               "first_name" => "some updated first_name",
               "last_name" => "some updated last_name",
               "phone" => "some updated phone"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, patient: patient} do
      conn = put(conn, ~p"/api/patients/#{patient}", patient: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete patient" do
    setup [:create_patient]

    test "deletes chosen patient", %{conn: conn, patient: patient} do
      conn = delete(conn, ~p"/api/patients/#{patient}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/patients/#{patient}")
      end
    end
  end

  defp create_patient(_) do
    patient = patient_fixture()
    %{patient: patient}
  end
end
