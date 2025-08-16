defmodule MiniProjectWeb.Admin.PatientControllerTest do
  use MiniProjectWeb.ConnCase

  import MiniProject.ClinicFixtures

  @create_attrs %{first_name: "some first_name", last_name: "some last_name", phone: "some phone", birthdate: ~D[2025-08-13], email: "some_email@mail.com"}
  @update_attrs %{first_name: "some updated first_name", last_name: "some updated last_name", phone: "some updated phone", birthdate: ~D[2025-08-14], email: "some_updated_email@mail.com"}
  @invalid_attrs %{first_name: nil, last_name: nil, phone: nil, birthdate: nil, email: nil}

  setup :register_and_log_in_user
  describe "index" do
    test "lists all patients", %{conn: conn} do
      conn = get(conn, ~p"/admin/patients")
      assert html_response(conn, 200) =~ "Pacientes"
    end
  end

  describe "new patient" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/admin/patients/new")
      assert html_response(conn, 200) =~ "New Patient"
    end
  end

  describe "create patient" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/admin/patients", patient: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/admin/patients/#{id}"

      conn = get(conn, ~p"/admin/patients/#{id}")
      assert html_response(conn, 200) =~ "Patient #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/admin/patients", patient: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Patient"
    end
  end

  describe "edit patient" do
    setup [:create_patient]

    test "renders form for editing chosen patient", %{conn: conn, patient: patient} do
      conn = get(conn, ~p"/admin/patients/#{patient}/edit")
      assert html_response(conn, 200) =~ "Edit Patient"
    end
  end

  describe "update patient" do
    setup [:create_patient]

    test "redirects when data is valid", %{conn: conn, patient: patient} do
      conn = put(conn, ~p"/admin/patients/#{patient}", patient: @update_attrs)
      assert redirected_to(conn) == ~p"/admin/patients/#{patient}"

      conn = get(conn, ~p"/admin/patients/#{patient}")
      assert html_response(conn, 200) =~ "some updated first_name"
    end

    test "renders errors when data is invalid", %{conn: conn, patient: patient} do
      conn = put(conn, ~p"/admin/patients/#{patient}", patient: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Patient"
    end
  end

  describe "delete patient" do
    setup [:create_patient]

    test "deletes chosen patient", %{conn: conn, patient: patient} do
      conn = delete(conn, ~p"/admin/patients/#{patient}")
      assert redirected_to(conn) == ~p"/admin/patients"

      assert_error_sent 404, fn ->
        get(conn, ~p"/admin/patients/#{patient}")
      end
    end
  end

  defp create_patient(_) do
    patient = patient_fixture()
    %{patient: patient}
  end
end
