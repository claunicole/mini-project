defmodule MiniProject.Clinic do
  @moduledoc """
  The Clinic context.
  """

  import Ecto.Query, warn: false
  alias MiniProject.Repo
  alias MiniProject.Clinic.{Patient, Practitioner, Prescription}

   # ---------- Paginate for patients ----------

  def paginate_patients(params \\ %{}) do
    base =
      from p in Patient,
        select: p

    base =
      case Map.get(params, "q") do
        nil -> base
        "" -> base
        q ->
          like = "%#{String.trim(q)}%"
          from p in base,
            where: like(p.first_name, ^like) or like(p.last_name, ^like)
      end

    Flop.validate_and_run(base, params, for: Patient, repo: Repo)
    # → {:ok, {records, meta}} | {:error, changeset}
  end


    # ---------- Paginate for practitioners ----------

    def paginate_practitioners(params \\ %{}) do
    base = from pr in Practitioner, select: pr

    base =
      case Map.get(params, "q") do
        nil -> base
        "" -> base
        q ->
          like = "%#{String.trim(q)}%"
          from pr in base,
            where: like(pr.first_name, ^like) or like(pr.last_name, ^like)
      end

    Flop.validate_and_run(base, params, for: Practitioner, repo: Repo)
  end

  # ---------- Paginate for prescriptions ----------

  def paginate_prescriptions(params \\ %{}) do
    base =
      from r in Prescription,
        as: :prescription,
        left_join: p  in assoc(r, :patient),      as: :patient,
        left_join: dr in assoc(r, :practitioner), as: :practitioner,
        preload: [patient: p, practitioner: dr]

    base =
      case Map.get(params, "q") |> to_string() |> String.trim() do
        "" -> base
        q ->
          pattern = "%#{String.downcase(q)}%"
          from [prescription: _r, patient: p, practitioner: dr] in base,
            where:
              like(fragment("LOWER(CONCAT(?, ' ', ?))", p.first_name,  p.last_name),  ^pattern) or
              like(fragment("LOWER(CONCAT(?, ' ', ?))", dr.first_name, dr.last_name), ^pattern)
      end

    Flop.validate_and_run(base, params, for: Prescription, repo: Repo)
  end

  # ---------- Loaders for fake data ----------

  @faker_url_patients "https://fakerapi.it/api/v1/persons?_locale=es_ES&_quantity=100"
  @faker_url_practitioners "https://fakerapi.it/api/v1/persons?_locale=es_ES&_quantity=100"

  @doc "Downlads and inserts fake patients into the database."
  def loader_patients do
    do_loader(@faker_url_patients, Patient)
  end 

  @doc "Downlads and inserts fake practitioners into the database."
  def loader_practitioners do
    do_loader(@faker_url_practitioners, Practitioner)
  end

  defp do_loader(url, schema_mod) do
    headers = [{"accept", "application/json"}]
    opts    = [timeout: 10_000, recv_timeout: 15_000]

    case HTTPoison.get(url, headers, opts) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        with {:ok, %{"data" => people}} <- Jason.decode(body) do
          {ok_count, errors} =
            people
            |> Enum.map(&map_person/1)
            |> Enum.reject(&(&1 == %{}))  
            |> Enum.reduce({0, []}, fn attrs, {ok, errs} ->
              changeset = apply(schema_mod, :changeset, [struct(schema_mod), attrs])
              case Repo.insert(changeset) do
                {:ok, _}     -> {ok + 1, errs}
                {:error, cs} -> {ok, [{attrs[:email], cs.errors} | errs]}
              end
            end)

          {:ok, ok_count, Enum.reverse(errors)}
        else
          {:error, decode_err} -> {:error, {:json_decode, decode_err}}
          _ -> {:error, :unexpected_payload}
        end

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, {:http_status, code, body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, {:httpoison, reason}}
    end
  end

  def loader_prescriptions(count \\ 300) do
    _ = Application.ensure_all_started(:faker)

    patient_ids      = from(p in Patient, select: p.id)      |> Repo.all()
    practitioner_ids = from(pr in Practitioner, select: pr.id)|> Repo.all()

    cond do
      patient_ids == [] -> {:error, :no_patients}
      practitioner_ids == [] -> {:error, :no_practitioners}
      true ->
        now = DateTime.utc_now() |> DateTime.truncate(:second)

        entries =
          1..count
          |> Enum.map(fn _ ->
            %{
              detail: lorem_detail(),
              patient_id: Enum.random(patient_ids),
              practitioner_id: Enum.random(practitioner_ids),
              inserted_at: now,
              updated_at: now
            }
          end)

        {inserted, _} = Repo.insert_all(Prescription, entries)
        {:ok, inserted}
    end
  end

  defp lorem_detail do
    Faker.Lorem.sentences(Enum.random(1..3)) |> Enum.join(" ")
  end

  def list_patients do
    Repo.all(Patient)
  end

  def delete_practitioner(%Practitioner{} = practitioner) do
    practitioner
    |> Practitioner.delete_changeset()
    |> Repo.delete()
  end

  def delete_patient(%Patient{} = patient) do
    patient
    |> Patient.delete_changeset()
    |> Repo.delete()
  end

  @doc """
  Gets a single patient.

  Raises `Ecto.NoResultsError` if the Patient does not exist.

  ## Examples

      iex> get_patient!(123)
      %Patient{}

      iex> get_patient!(456)
      ** (Ecto.NoResultsError)

  """
  def get_patient!(id), do: Repo.get!(Patient, id)

  @doc """
  Creates a patient.

  ## Examples

      iex> create_patient(%{field: value})
      {:ok, %Patient{}}

      iex> create_patient(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_patient(attrs \\ %{}) do
    %Patient{}
    |> Patient.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a patient.

  ## Examples

      iex> update_patient(patient, %{field: new_value})
      {:ok, %Patient{}}

      iex> update_patient(patient, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_patient(%Patient{} = patient, attrs) do
    patient
    |> Patient.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a patient.

  ## Examples

      iex> delete_patient(patient)
      {:ok, %Patient{}}

      iex> delete_patient(patient)
      {:error, %Ecto.Changeset{}}

  """
  def delete_patient(%Patient{} = patient) do
    Repo.delete(patient)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking patient changes.

  ## Examples

      iex> change_patient(patient)
      %Ecto.Changeset{data: %Patient{}}

  """
  def change_patient(%Patient{} = patient, attrs \\ %{}) do
    Patient.changeset(patient, attrs)
  end

  alias MiniProject.Clinic.Practitioner

  @doc """
  Returns the list of practitioners.

  ## Examples

      iex> list_practitioners()
      [%Practitioner{}, ...]

  """
  def list_practitioners do
    Repo.all(Practitioner)
  end

  @doc """
  Gets a single practitioner.

  Raises `Ecto.NoResultsError` if the Practitioner does not exist.

  ## Examples

      iex> get_practitioner!(123)
      %Practitioner{}

      iex> get_practitioner!(456)
      ** (Ecto.NoResultsError)

  """
  def get_practitioner!(id), do: Repo.get!(Practitioner, id)

  @doc """
  Creates a practitioner.

  ## Examples

      iex> create_practitioner(%{field: value})
      {:ok, %Practitioner{}}

      iex> create_practitioner(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_practitioner(attrs \\ %{}) do
    %Practitioner{}
    |> Practitioner.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a practitioner.

  ## Examples

      iex> update_practitioner(practitioner, %{field: new_value})
      {:ok, %Practitioner{}}

      iex> update_practitioner(practitioner, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_practitioner(%Practitioner{} = practitioner, attrs) do
    practitioner
    |> Practitioner.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a practitioner.

  ## Examples

      iex> delete_practitioner(practitioner)
      {:ok, %Practitioner{}}

      iex> delete_practitioner(practitioner)
      {:error, %Ecto.Changeset{}}

  """
  def delete_practitioner(%Practitioner{} = practitioner) do
    Repo.delete(practitioner)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking practitioner changes.

  ## Examples

      iex> change_practitioner(practitioner)
      %Ecto.Changeset{data: %Practitioner{}}

  """
  def change_practitioner(%Practitioner{} = practitioner, attrs \\ %{}) do
    Practitioner.changeset(practitioner, attrs)
  end

  alias MiniProject.Clinic.Prescription

  @doc """
  Returns the list of prescriptions.

  ## Examples

      iex> list_prescriptions()
      [%Prescription{}, ...]

  """
  def list_prescriptions do
    Repo.all(Prescription)
  end

  @doc """
  Gets a single prescription.

  Raises `Ecto.NoResultsError` if the Prescription does not exist.

  ## Examples

      iex> get_prescription!(123)
      %Prescription{}

      iex> get_prescription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_prescription!(id), do: Repo.get!(Prescription, id)

  @doc """
  Creates a prescription.

  ## Examples

      iex> create_prescription(%{field: value})
      {:ok, %Prescription{}}

      iex> create_prescription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_prescription(attrs \\ %{}) do
    %Prescription{}
    |> Prescription.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a prescription.

  ## Examples

      iex> update_prescription(prescription, %{field: new_value})
      {:ok, %Prescription{}}

      iex> update_prescription(prescription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_prescription(%Prescription{} = prescription, attrs) do
    prescription
    |> Prescription.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a prescription.

  ## Examples

      iex> delete_prescription(prescription)
      {:ok, %Prescription{}}

      iex> delete_prescription(prescription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_prescription(%Prescription{} = prescription) do
    Repo.delete(prescription)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking prescription changes.

  ## Examples

      iex> change_prescription(prescription)
      %Ecto.Changeset{data: %Prescription{}}

  """
  def change_prescription(%Prescription{} = prescription, attrs \\ %{}) do
    Prescription.changeset(prescription, attrs)
  end

  # ---- Helpers ----

  defp map_person(%{
         "firstname" => first,
         "lastname"  => last,
         "phone"     => phone,
         "email"     => email,
         "birthday"  => birthday
       }) do
    %{
      first_name: to_string(first),
      last_name:  to_string(last),
      phone:      to_string(phone),
      email:      email |> to_string() |> String.trim() |> String.downcase(),
      birthdate:  parse_date(birthday)
    }
  end

  defp map_person(_), do: %{}

  defp parse_date(nil), do: nil
  defp parse_date(str) when is_binary(str) do
    case Date.from_iso8601(str) do
      {:ok, d} -> d
      _ -> nil
    end
  end
end
