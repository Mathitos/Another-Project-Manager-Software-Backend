defmodule ApmsWeb.JwtView do
  use ApmsWeb, :view

  def render("jwt.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end
end
