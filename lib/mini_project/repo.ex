defmodule MiniProject.Repo do
  use Ecto.Repo,
    otp_app: :mini_project,
    adapter: Ecto.Adapters.MyXQL
end
