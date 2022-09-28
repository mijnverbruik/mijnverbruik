defmodule MijnverbruikWeb.PageController do
  use MijnverbruikWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
