defmodule MiniProjectWeb.Admin.PatientHTML do
  use MiniProjectWeb, :html

  embed_templates "patient_html/*"

  @doc """
  Renders a patient form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def patient_form(assigns)
end
