defmodule MiniProjectWeb.PageController do
 use MiniProjectWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
