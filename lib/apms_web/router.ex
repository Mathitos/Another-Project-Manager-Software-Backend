defmodule ApmsWeb.Router do
  use ApmsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :ensure_auth do
    plug ApmsWeb.Guardian.Pipeline
  end

  scope "/api/v1", ApmsWeb do
    pipe_through(:api)

    post("/sign_up", UserController, :create)
    post("/sign_in", UserController, :sign_in)
  end

  scope "/api/v1", ApmsWeb do
    pipe_through([:api, :ensure_auth])
    resources("/project", ProjectController)
    resources("/project/:project_id/task", TaskController)
  end
end
