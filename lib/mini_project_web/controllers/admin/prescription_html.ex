defmodule MiniProjectWeb.Admin.PrescriptionHTML do
  use MiniProjectWeb, :html

  embed_templates "prescription_html/*"

  @doc """
  Renders a prescription form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def prescription_form(assigns)
end
