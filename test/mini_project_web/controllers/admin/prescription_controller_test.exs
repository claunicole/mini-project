defmodule MiniProjectWeb.Admin.PrescriptionControllerTest do
  use MiniProjectWeb.ConnCase

  import MiniProject.ClinicFixtures

  @create_attrs %{detail: "some detail"}
  @update_attrs %{detail: "some updated detail"}
  @invalid_attrs %{detail: nil}

  setup :register_and_log_in_user
  describe "index" do
    test "lists all prescriptions", %{conn: conn} do
      conn = get(conn, ~p"/admin/prescriptions")
      assert html_response(conn, 200) =~ "Recetas"
    end
  end
end
