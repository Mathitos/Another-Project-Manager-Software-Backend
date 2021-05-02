defmodule ApmsWeb.Router do
  use ApmsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ApmsWeb do
    pipe_through :api
  end
end
