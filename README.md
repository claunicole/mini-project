# MiniProject


## Install and setup dependencies
  mix setup

## Create database and run migrations
  mix ecto.setup 

## Generator for patients
  mix phx.gen.html Clinic Patient patients first_name:string last_name:string phone:string birthdate:date email:string --web admin

## Generator for practitioners
  mix phx.gen.html Clinic Practitioner practitioners first_name:string last_name:string phone:string birthdate:date email:string --web admin

## Generator for prescriptions
  mix phx.gen.html Clinic Prescription prescriptions detail:text practitioner_id:references:practitioners patient_id:references:patients --web admin

## Insert data
### run console: iex -S mix
  MiniProject.Clinic.loader_patients()
  MiniProject.Clinic.loader_practitioners()
  MiniProject.Clinic.loader_prescriptions()

## Create new user
### run console: iex -S mix
  1. alias MiniProject.Accounts
  2. {:ok, user} =
      Accounts.register_user(%{
        email: "admin@example.com",
        password: "supersecret123"
     })

## Run server :mix phx.server
  Visit [`localhost:4000`](http://localhost:4000) from your browser.


## Generators for API
### /api/patients
  mix phx.gen.json Clinic Patient patients first_name:string last_name:string phone:string birthdate:date email:string --web api --no-context --no-schema

### /api/practitioners
  mix phx.gen.json Clinic Practitioner practitioners first_name:string last_name:string phone:string birthdate:date email:string --web api --no-context --no-schema

### /api/prescriptions
  mix phx.gen.json Clinic Prescription prescriptions detail:string practitioner_id:references:practitioners patient_id:references:patients --web api --no-context --no-schema

# API Docs

## Patients
### Index: GET /api/patients
### Show: GET /api/patients/:id
### Create: POST /api/patients
  Body:
  {
    "patient": {
      "first_name": "Ada",
      "last_name": "Lovelace",
      "email": "ada@example.com",
      "phone": "+1 555 0000",
      "birthdate": "1815-12-10"
    }
  }

### Update: PUT /api/patients/:id
  Body:
  { "patient": { "phone": "+1 555 1111" } }

### Delete: DELETE /api/patients/:id

## Practitioners
### Index: GET /api/practitioners
### Show: GET /api/practitioners/:id
### Create: POST /api/practitioners
  Body:
  {
    "practitioner": {
      "first_name": "Gregory",
      "last_name": "House",
      "email": "house@example.com",
      "phone": "+1 555 2222",
      "birthdate": "1959-06-11"
    }
  }

### Update: PUT /api/practitioners/:id
  Body:
  { "practitioner": { "phone": "+1 555 3333" } }

### Delete: DELETE /api/practitioners/:id

## Prescriptions (patient and practitioner must exist)
### Index: GET /api/prescriptions
### Show: GET /api/prescriptions/:id
### Create: POST /api/prescriptions
Body:
{
  "prescription": {
    "detail": "Lorem ipsum",
    "patient_id": 1,
    "practitioner_id": 2
  }
}

### Update: PUT /api/prescriptions/:id
  Body:
  { "prescription": { "detail": "New detail..." } }

### Delete: DELETE /api/prescriptions/:id


## TEST create: 
### can't create a prescription when detail is too short
Verifies server-side validation on Prescription.detail. If the text is shorter than 5 characters, the API must reject the request with HTTP 422 Unprocessable Entity and return a validation error for detail.

### Test name: returns 422 when detail is too short
  test/mini_project_web/controllers/api/prescription_controller_test.exs

### Run test:
  mix test test/mini_project_web/controllers/api/prescription_controller_test.exs
