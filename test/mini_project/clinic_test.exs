defmodule MiniProject.ClinicTest do
  use MiniProject.DataCase

  alias MiniProject.Clinic

  describe "patients" do
    alias MiniProject.Clinic.Patient

    import MiniProject.ClinicFixtures

    @invalid_attrs %{first_name: nil, last_name: nil, phone: nil, birthdate: nil, email: nil}

    test "list_patients/0 returns all patients" do
      patient = patient_fixture()
      assert Clinic.list_patients() == [patient]
    end

    test "get_patient!/1 returns the patient with given id" do
      patient = patient_fixture()
      assert Clinic.get_patient!(patient.id) == patient
    end

    test "create_patient/1 with valid data creates a patient" do
      valid_attrs = %{first_name: "some first_name", last_name: "some last_name", phone: "some phone", birthdate: ~D[2025-08-13], email: "some@email.com"}

      assert {:ok, %Patient{} = patient} = Clinic.create_patient(valid_attrs)
      assert patient.first_name == "some first_name"
      assert patient.last_name == "some last_name"
      assert patient.phone == "some phone"
      assert patient.birthdate == ~D[2025-08-13]
      assert patient.email == "some@email.com"
    end

    test "create_patient/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clinic.create_patient(@invalid_attrs)
    end

    test "update_patient/2 with valid data updates the patient" do
      patient = patient_fixture()
      update_attrs = %{first_name: "some updated first_name", last_name: "some updated last_name", phone: "some updated phone", birthdate: ~D[2025-08-14], email: "some_email2@mail.com"}

      assert {:ok, %Patient{} = patient} = Clinic.update_patient(patient, update_attrs)
      assert patient.first_name == "some updated first_name"
      assert patient.last_name == "some updated last_name"
      assert patient.phone == "some updated phone"
      assert patient.birthdate == ~D[2025-08-14]
      assert patient.email == "some_email2@mail.com"
    end

    test "update_patient/2 with invalid data returns error changeset" do
      patient = patient_fixture()
      assert {:error, %Ecto.Changeset{}} = Clinic.update_patient(patient, @invalid_attrs)
      assert patient == Clinic.get_patient!(patient.id)
    end

    test "delete_patient/1 deletes the patient" do
      patient = patient_fixture()
      assert {:ok, %Patient{}} = Clinic.delete_patient(patient)
      assert_raise Ecto.NoResultsError, fn -> Clinic.get_patient!(patient.id) end
    end

    test "change_patient/1 returns a patient changeset" do
      patient = patient_fixture()
      assert %Ecto.Changeset{} = Clinic.change_patient(patient)
    end
  end

  describe "practitioners" do
    alias MiniProject.Clinic.Practitioner

    import MiniProject.ClinicFixtures

    @invalid_attrs %{first_name: nil, last_name: nil, phone: nil, birthdate: nil, email: nil}

    test "list_practitioners/0 returns all practitioners" do
      practitioner = practitioner_fixture()
      assert Clinic.list_practitioners() == [practitioner]
    end

    test "get_practitioner!/1 returns the practitioner with given id" do
      practitioner = practitioner_fixture()
      assert Clinic.get_practitioner!(practitioner.id) == practitioner
    end

    test "create_practitioner/1 with valid data creates a practitioner" do
      valid_attrs = %{first_name: "some first_name", last_name: "some last_name", phone: "some phone", birthdate: ~D[2025-08-13], email: "some@email.com"}

      assert {:ok, %Practitioner{} = practitioner} = Clinic.create_practitioner(valid_attrs)
      assert practitioner.first_name == "some first_name"
      assert practitioner.last_name == "some last_name"
      assert practitioner.phone == "some phone"
      assert practitioner.birthdate == ~D[2025-08-13]
      assert practitioner.email == "some@email.com"
    end

    test "create_practitioner/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clinic.create_practitioner(@invalid_attrs)
    end

    test "update_practitioner/2 with valid data updates the practitioner" do
      practitioner = practitioner_fixture()
      update_attrs = %{first_name: "some updated first_name", last_name: "some updated last_name", phone: "some updated phone", birthdate: ~D[2025-08-14], email: "some_email2@mail.com"}

      assert {:ok, %Practitioner{} = practitioner} = Clinic.update_practitioner(practitioner, update_attrs)
      assert practitioner.first_name == "some updated first_name"
      assert practitioner.last_name == "some updated last_name"
      assert practitioner.phone == "some updated phone"
      assert practitioner.birthdate == ~D[2025-08-14]
      assert practitioner.email == "some_email2@mail.com"
    end

    test "update_practitioner/2 with invalid data returns error changeset" do
      practitioner = practitioner_fixture()
      assert {:error, %Ecto.Changeset{}} = Clinic.update_practitioner(practitioner, @invalid_attrs)
      assert practitioner == Clinic.get_practitioner!(practitioner.id)
    end

    test "delete_practitioner/1 deletes the practitioner" do
      practitioner = practitioner_fixture()
      assert {:ok, %Practitioner{}} = Clinic.delete_practitioner(practitioner)
      assert_raise Ecto.NoResultsError, fn -> Clinic.get_practitioner!(practitioner.id) end
    end

    test "change_practitioner/1 returns a practitioner changeset" do
      practitioner = practitioner_fixture()
      assert %Ecto.Changeset{} = Clinic.change_practitioner(practitioner)
    end
  end

  describe "prescriptions" do
    alias MiniProject.Clinic.Prescription

    import MiniProject.ClinicFixtures

    @invalid_attrs %{detail: nil}

    setup do
      %{patient: patient_fixture(), practitioner: practitioner_fixture()}
    end

    test "list_prescriptions/0 returns all prescriptions" do
      prescription = prescription_fixture()
      assert Clinic.list_prescriptions() == [prescription]
    end

    test "get_prescription!/1 returns the prescription with given id" do
      prescription = prescription_fixture()
      assert Clinic.get_prescription!(prescription.id) == prescription
    end

    test "create_prescription/1 with valid data creates a prescription",
      %{patient: patient, practitioner: practitioner} do
      valid_attrs = %{
        detail: "some detail",
        patient_id: patient.id,
        practitioner_id: practitioner.id
      }

      assert {:ok, %Prescription{} = prescription} =
              MiniProject.Clinic.create_prescription(valid_attrs)

      assert prescription.detail == "some detail"
      assert prescription.patient_id == patient.id
      assert prescription.practitioner_id == practitioner.id
    end

    test "create_prescription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Clinic.create_prescription(@invalid_attrs)
    end

    test "update_prescription/2 with valid data updates the prescription" do
      prescription = prescription_fixture()
      update_attrs = %{detail: "some updated detail"}

      assert {:ok, %Prescription{} = prescription} = Clinic.update_prescription(prescription, update_attrs)
      assert prescription.detail == "some updated detail"
    end

    test "update_prescription/2 with invalid data returns error changeset" do
      prescription = prescription_fixture()
      assert {:error, %Ecto.Changeset{}} = Clinic.update_prescription(prescription, @invalid_attrs)
      assert prescription == Clinic.get_prescription!(prescription.id)
    end

    test "delete_prescription/1 deletes the prescription" do
      prescription = prescription_fixture()
      assert {:ok, %Prescription{}} = Clinic.delete_prescription(prescription)
      assert_raise Ecto.NoResultsError, fn -> Clinic.get_prescription!(prescription.id) end
    end

    test "change_prescription/1 returns a prescription changeset" do
      prescription = prescription_fixture()
      assert %Ecto.Changeset{} = Clinic.change_prescription(prescription)
    end
  end
end
