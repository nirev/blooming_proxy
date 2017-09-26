defmodule BoomingProxyWeb.Router do
  use BoomingProxyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BoomingProxyWeb do
    pipe_through :api

    get "/clients.json", ClientController, :index
    get "/invoices.json", InvoiceController, :index
  end

end
