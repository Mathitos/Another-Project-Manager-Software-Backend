defmodule ApmsWeb.ErrorView do
  use ApmsWeb, :view

  def render("500.json", _assigns) do
    %{errors: %{detail: "Internal Server Error"}}
  end

  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
